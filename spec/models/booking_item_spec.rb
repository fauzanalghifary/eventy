require 'rails_helper'

RSpec.describe BookingItem, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:booking) }
    it { is_expected.to belong_to(:ticket_type) }
  end

  describe "validations" do
    it { is_expected.to validate_numericality_of(:quantity).only_integer.is_greater_than(0) }

    it "requires the ticket type to belong to the booking event" do
      booking = build(:booking)
      ticket_type = build(:ticket_type, event: build(:event))
      booking_item = build(:booking_item, booking:, ticket_type:)

      expect(booking_item).not_to be_valid
      expect(booking_item.errors[:ticket_type]).to include("must belong to the booking event")
    end
  end
end
