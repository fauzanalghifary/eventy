# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :create_booking, mutation: Mutations::CreateBooking
  end
end
