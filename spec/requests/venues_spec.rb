require 'rails_helper'

RSpec.describe 'Venues API', type: :request do
  describe 'venues query' do
    let!(:venue) { create(:venue, name: 'Test Venue') }
    let(:query) do
      <<~GQL
        query {
          venues {
            id
            name
          }
        }
      GQL
    end

    it 'returns a list of venues' do
      # Execute the request
      post '/graphql', params: { query: query }

      # Parse response
      json = response.parsed_body
      venues = json['data']['venues']

      # Assertions
      expect(response).to have_http_status(:success)
      expect(venues).to be_an(Array)
      expect(venues.first['name']).to eq('Test Venue')
    end
  end
end
