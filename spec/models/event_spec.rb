require 'rails_helper'

RSpec.describe Event, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:venue) }
    it { is_expected.to have_many(:ticket_types).dependent(:destroy) }
    it { is_expected.to have_many(:bookings).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
  end
end
