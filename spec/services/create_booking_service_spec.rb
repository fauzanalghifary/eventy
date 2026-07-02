require 'rails_helper'

RSpec.describe CreateBookingService do
  describe "#call" do
    let(:event) { create(:event) }
    let(:booking_date) { Date.new(2026, 7, 10) }
    let(:adult_ticket) { create(:ticket_type, event: event, name: "Adult", capacity: 2) }
    let(:child_ticket) { create(:ticket_type, event: event, name: "Child", capacity: 3) }

    it "creates a booking with booking items when capacity is available" do
      result = described_class.new(
        event_id: event.id,
        booking_date: booking_date,
        ticket_selections: [
          { ticket_type_id: adult_ticket.id, quantity: 1 },
          { ticket_type_id: child_ticket.id, quantity: 2 }
        ]
      ).call

      expect(result).to be_success
      expect(result.booking).to be_persisted
      expect(result.booking.confirmation_code).to be_present
      expect(result.booking.booking_items.count).to eq(2)
      expect(result.booking.booking_items.sum(:quantity)).to eq(3)
    end

    it "does not create a booking when requested quantity exceeds remaining capacity" do
      existing_booking = create(:booking, event: event, booking_date: booking_date)
      create(:booking_item, booking: existing_booking, ticket_type: adult_ticket, quantity: 2)

      expect do
        result = described_class.new(
          event_id: event.id,
          booking_date: booking_date,
          ticket_selections: [
            { ticket_type_id: adult_ticket.id, quantity: 1 }
          ]
        ).call

        expect(result).not_to be_success
        expect(result.errors).to include("Adult has only 0 tickets remaining")
      end.not_to change(Booking, :count)
    end

    it "creates a booking when requested quantity exactly matches remaining capacity" do
      existing_booking = create(:booking, event: event, booking_date: booking_date)
      create(:booking_item, booking: existing_booking, ticket_type: adult_ticket, quantity: 1)

      result = described_class.new(
        event_id: event.id,
        booking_date: booking_date,
        ticket_selections: [
          { ticket_type_id: adult_ticket.id, quantity: 1 }
        ]
      ).call

      expect(result).to be_success
      expect(result.booking.booking_items.sole.quantity).to eq(1)
    end

    it "calculates remaining capacity per date" do
      existing_booking = create(:booking, event: event, booking_date: booking_date - 1.day)
      create(:booking_item, booking: existing_booking, ticket_type: adult_ticket, quantity: 2)

      result = described_class.new(
        event_id: event.id,
        booking_date: booking_date,
        ticket_selections: [
          { ticket_type_id: adult_ticket.id, quantity: 2 }
        ]
      ).call

      expect(result).to be_success
    end

    it "aggregates duplicate ticket selections before checking capacity" do
      result = described_class.new(
        event_id: event.id,
        booking_date: booking_date,
        ticket_selections: [
          { ticket_type_id: adult_ticket.id, quantity: 1 },
          { ticket_type_id: adult_ticket.id, quantity: 2 }
        ]
      ).call

      expect(result).not_to be_success
      expect(result.errors).to include("Adult has only 2 tickets remaining")
    end

    it "rejects ticket types that do not belong to the event" do
      other_event = create(:event)
      other_ticket = create(:ticket_type, event: other_event, name: "Member")

      result = described_class.new(
        event_id: event.id,
        booking_date: booking_date,
        ticket_selections: [
          { ticket_type_id: other_ticket.id, quantity: 1 }
        ]
      ).call

      expect(result).not_to be_success
      expect(result.errors).to include("Member does not belong to #{event.name}")
    end

    it "returns an error when the event does not exist" do
      result = described_class.new(
        event_id: -1,
        booking_date: booking_date,
        ticket_selections: [
          { ticket_type_id: adult_ticket.id, quantity: 1 }
        ]
      ).call

      expect(result).not_to be_success
      expect(result.errors).to include("Event not found")
    end
  end
end
