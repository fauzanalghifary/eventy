require 'rails_helper'

RSpec.describe 'Bookings API', type: :request do
  describe 'createBooking mutation' do
    let(:event) { create(:event) }
    let!(:adult_ticket) { create(:ticket_type, event: event, name: 'Adult', capacity: 2) }
    let(:booking_date) { Date.new(2026, 7, 10) }
    let(:mutation) do
      <<~GQL
        mutation CreateBooking($input: BookingInput!) {
          createBooking(input: $input) {
            booking {
              id
              confirmationCode
            }
            errors
          }
        }
      GQL
    end

    it 'creates a booking' do
      expect do
        post '/graphql', params: {
          query: mutation,
          variables: {
            input: {
              eventId: event.id,
              bookingDate: booking_date.iso8601,
              ticketSelections: [
                { ticketTypeId: adult_ticket.id, quantity: 1 }
              ]
            }
          }
        }, as: :json
      end.to change(Booking, :count).by(1)

      json = response.parsed_body

      expect(response).to have_http_status(:success)
      expect(json['errors']).to be_nil
      expect(json.dig('data', 'createBooking', 'booking', 'confirmationCode')).to be_present
      expect(json.dig('data', 'createBooking', 'errors')).to eq([])
    end

    it 'returns service errors when capacity is exceeded' do
      booking = create(:booking, event: event, booking_date: booking_date)
      create(:booking_item, booking: booking, ticket_type: adult_ticket, quantity: 2)

      expect do
        post '/graphql', params: {
          query: mutation,
          variables: {
            input: {
              eventId: event.id,
              bookingDate: booking_date.iso8601,
              ticketSelections: [
                { ticketTypeId: adult_ticket.id, quantity: 1 }
              ]
            }
          }
        }, as: :json
      end.not_to change(Booking, :count)

      json = response.parsed_body

      expect(response).to have_http_status(:success)
      expect(json['errors']).to be_nil
      expect(json.dig('data', 'createBooking', 'booking')).to be_nil
      expect(json.dig('data', 'createBooking', 'errors')).to include('Adult has only 0 tickets remaining')
    end
  end
end
