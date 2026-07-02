require 'rails_helper'

RSpec.describe TicketType, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:event) }
    it { is_expected.to have_many(:booking_items).dependent(:restrict_with_error) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_numericality_of(:price_cents).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_numericality_of(:capacity).only_integer.is_greater_than(0) }
  end

  describe "#remaining_capacity_on" do
    it "subtracts booked quantity for the given date" do
      ticket_type = create(:ticket_type, capacity: 5)
      booking = create(:booking, event: ticket_type.event, booking_date: Date.new(2026, 7, 10))
      create(:booking_item, booking: booking, ticket_type: ticket_type, quantity: 2)

      expect(ticket_type.remaining_capacity_on(Date.new(2026, 7, 10))).to eq(3)
    end

    it "ignores bookings for other dates" do
      ticket_type = create(:ticket_type, capacity: 5)
      booking = create(:booking, event: ticket_type.event, booking_date: Date.new(2026, 7, 9))
      create(:booking_item, booking: booking, ticket_type: ticket_type, quantity: 2)

      expect(ticket_type.remaining_capacity_on(Date.new(2026, 7, 10))).to eq(5)
    end
  end
end
