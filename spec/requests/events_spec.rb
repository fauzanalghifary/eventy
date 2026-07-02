require 'rails_helper'

RSpec.describe 'Events API', type: :request do
  describe 'event availability query' do
    let(:event) { create(:event, name: 'Evening Safari') }
    let!(:adult_ticket) { create(:ticket_type, event: event, name: 'Adult', price_cents: 2_500, capacity: 5) }
    let!(:child_ticket) { create(:ticket_type, event: event, name: 'Child', price_cents: 1_500, capacity: 3) }
    let(:booking_date) { Date.new(2026, 7, 10) }
    let(:query) do
      <<~GQL
        query EventAvailability($eventId: ID!, $date: ISO8601Date!) {
          event(id: $eventId) {
            name
            ticketTypes {
            name
            price
            remainingCapacity(date: $date)
          }
          }
        }
      GQL
    end

    it 'returns ticket type availability for the requested date' do
      booking = create(:booking, event: event, booking_date: booking_date)
      create(:booking_item, booking: booking, ticket_type: adult_ticket, quantity: 2)

      post '/graphql', params: {
        query: query,
        variables: {
          eventId: event.id,
          date: booking_date.iso8601
        }
      }

      json = response.parsed_body
      ticket_types = json.dig('data', 'event', 'ticketTypes')

      expect(response).to have_http_status(:success)
      expect(json['errors']).to be_nil
      expect(json.dig('data', 'event', 'name')).to eq('Evening Safari')
      expect(ticket_types).to contain_exactly(
        { 'name' => 'Adult', 'price' => 2_500, 'remainingCapacity' => 3 },
        { 'name' => 'Child', 'price' => 1_500, 'remainingCapacity' => 3 }
      )
    end
  end
end
