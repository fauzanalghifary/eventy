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

  describe ".booked_quantities_on" do
    it "returns booked quantities grouped by ticket type for the given date" do
      event = create(:event)
      adult_ticket = create(:ticket_type, event: event, name: "Adult")
      child_ticket = create(:ticket_type, event: event, name: "Child")
      booking = create(:booking, event: event, booking_date: Date.new(2026, 7, 10))
      other_date_booking = create(:booking, event: event, booking_date: Date.new(2026, 7, 11))

      create(:booking_item, booking: booking, ticket_type: adult_ticket, quantity: 2)
      create(:booking_item, booking: booking, ticket_type: child_ticket, quantity: 1)
      create(:booking_item, booking: other_date_booking, ticket_type: adult_ticket, quantity: 1)

      expect(
        described_class.booked_quantities_on(
          ticket_type_ids: [adult_ticket.id, child_ticket.id],
          booking_date: Date.new(2026, 7, 10)
        )
      ).to eq(adult_ticket.id => 2, child_ticket.id => 1)
    end
  end
end
