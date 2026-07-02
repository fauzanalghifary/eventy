module Types
  class TicketTypeType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :price, Integer, null: false
    field :price_cents, Integer, null: false
    field :capacity, Integer, null: false
    field :remaining_capacity, Integer, null: false do
      argument :date, GraphQL::Types::ISO8601Date, required: true
    end

    def remaining_capacity(date:)
      booked_quantity = dataloader
        .with(Sources::TicketTypeAvailabilitySource, date)
        .load(object.id)

      object.capacity - booked_quantity
    end

    def price
      object.price_cents
    end

    def price_cents
      object.price_cents
    end
  end
end
