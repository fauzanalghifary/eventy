module Types
  class BookingItemType < Types::BaseObject
    field :id, ID, null: false
    field :ticket_type, Types::TicketTypeType, null: false
    field :quantity, Integer, null: false
  end
end
