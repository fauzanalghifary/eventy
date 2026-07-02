module Types
  class BookingInputType < Types::BaseInputObject
    argument :event_id, ID, required: true
    argument :date, GraphQL::Types::ISO8601Date, required: true
    argument :ticket_selections, [ Types::TicketSelectionInputType ], required: true
  end
end
