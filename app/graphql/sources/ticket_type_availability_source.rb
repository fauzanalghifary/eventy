module Sources
  class TicketTypeAvailabilitySource < GraphQL::Dataloader::Source
    def initialize(date)
      @date = date
    end

    def fetch(ticket_type_ids)
      booked_quantities = TicketType.booked_quantities_on(
        ticket_type_ids: ticket_type_ids,
        booking_date: date
      )

      ticket_type_ids.map { |ticket_type_id| booked_quantities.fetch(ticket_type_id, 0) }
    end

    private

    attr_reader :date
  end
end
