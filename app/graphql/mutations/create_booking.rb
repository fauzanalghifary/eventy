module Mutations
  class CreateBooking < GraphQL::Schema::Mutation
    argument_class Types::BaseArgument
    field_class Types::BaseField

    argument :input, Types::BookingInputType, required: true

    field :booking, Types::BookingType, null: true
    field :errors, [ String ], null: false

    def resolve(input:)
      result = CreateBookingService.new(
        event_id: input[:event_id],
        booking_date: input[:date],
        ticket_selections: input[:ticket_selections].map do |selection|
          {
            ticket_type_id: selection[:ticket_type_id],
            quantity: selection[:quantity]
          }
        end
      ).call

      {
        booking: result.booking,
        errors: result.errors
      }
    end
  end
end
