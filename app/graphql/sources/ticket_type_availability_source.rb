module Sources
  class TicketTypeAvailabilitySource < GraphQL::Dataloader::Source
    def initialize(date)
      @date = date
    end

    def fetch(ticket_type_ids)
      booked_quantities = BookingItem
        .joins(:booking)
        .where(ticket_type_id: ticket_type_ids)
        .where(bookings: { booking_date: date })
        .group(:ticket_type_id)
        .sum(:quantity)

      ticket_type_ids.map { |ticket_type_id| booked_quantities.fetch(ticket_type_id, 0) }
    end

    private

    attr_reader :date
  end
end
