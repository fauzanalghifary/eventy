class CreateBookingService
  Result = Struct.new(:booking, :errors, keyword_init: true) do
    def success?
      errors.empty?
    end
  end

  def initialize(event_id:, booking_date:, ticket_selections:)
    @event_id = event_id
    @booking_date = booking_date
    @ticket_selections = ticket_selections
  end

  def call
    create_booking
  rescue ActiveRecord::RecordNotUnique
    failure("Could not generate a unique confirmation code")
  rescue ActiveRecord::RecordInvalid => error
    failure(error.record.errors.full_messages)
  end

  private

  attr_reader :event_id, :booking_date, :ticket_selections

  def create_booking
    event = Event.find_by(id: event_id)
    return failure("Event not found") if event.blank?

    normalized_booking_date = normalize_booking_date
    return failure("Booking date is invalid") if normalized_booking_date.blank?

    quantities_by_ticket_type_id, selection_errors = normalize_ticket_selections
    return failure(selection_errors) if selection_errors.any?
    return failure("Ticket selections can't be blank") if quantities_by_ticket_type_id.blank?

    result = nil

    Booking.transaction do
      ticket_types = TicketType
        .where(id: quantities_by_ticket_type_id.keys)
        .order(:id)
        .lock
        .to_a

      validation_errors = validate_ticket_types(
        event: event,
        ticket_types: ticket_types,
        quantities_by_ticket_type_id: quantities_by_ticket_type_id,
        booking_date: normalized_booking_date
      )

      if validation_errors.any?
        result = failure(validation_errors)
        raise ActiveRecord::Rollback
      end

      booking = event.bookings.create!(
        booking_date: normalized_booking_date,
        confirmation_code: generate_confirmation_code
      )

      ticket_types.each do |ticket_type|
        booking.booking_items.create!(
          ticket_type: ticket_type,
          quantity: quantities_by_ticket_type_id.fetch(ticket_type.id)
        )
      end

      result = success(booking)
    end

    result
  end

  def normalize_booking_date
    booking_date.to_date
  rescue NoMethodError, Date::Error
    nil
  end

  def normalize_ticket_selections
    errors = []
    quantities = Array(ticket_selections).each_with_object(Hash.new(0)) do |selection, memo|
      ticket_type_id = selection[:ticket_type_id] || selection["ticket_type_id"]
      quantity = selection[:quantity] || selection["quantity"]

      next if ticket_type_id.blank?

      quantity = quantity.to_i
      if quantity <= 0
        errors << "Ticket type #{ticket_type_id} quantity must be greater than 0"
        next
      end

      memo[ticket_type_id.to_i] += quantity
    end

    [quantities, errors]
  end

  def validate_ticket_types(event:, ticket_types:, quantities_by_ticket_type_id:, booking_date:)
    errors = []
    ticket_types_by_id = ticket_types.index_by(&:id)

    missing_ticket_type_ids = quantities_by_ticket_type_id.keys - ticket_types_by_id.keys
    missing_ticket_type_ids.each do |ticket_type_id|
      errors << "Ticket type #{ticket_type_id} not found"
    end

    ticket_types.each do |ticket_type|
      if ticket_type.event_id != event.id
        errors << "#{ticket_type.name} does not belong to #{event.name}"
        next
      end

      requested_quantity = quantities_by_ticket_type_id.fetch(ticket_type.id)
      remaining_capacity = ticket_type.remaining_capacity_on(booking_date)

      next if requested_quantity <= remaining_capacity

      errors << "#{ticket_type.name} has only #{remaining_capacity} tickets remaining"
    end

    errors
  end

  def generate_confirmation_code
    loop do
      code = SecureRandom.alphanumeric(10).upcase
      return code unless Booking.exists?(confirmation_code: code)
    end
  end

  def success(booking)
    Result.new(booking: booking, errors: [])
  end

  def failure(errors)
    Result.new(booking: nil, errors: Array(errors))
  end
end
