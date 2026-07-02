module Types
  class BookingType < Types::BaseObject
    field :id, ID, null: false
    field :confirmation_code, String, null: false
    field :booking_date, GraphQL::Types::ISO8601Date, null: false
    field :event, Types::EventType, null: false
    field :booking_items, [ Types::BookingItemType ], null: false
  end
end
