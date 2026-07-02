require 'rails_helper'

RSpec.describe Booking, type: :model do
  subject(:booking) { build(:booking) }

  describe "associations" do
    it { is_expected.to belong_to(:event) }
    it { is_expected.to have_many(:booking_items).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:booking_date) }
    it { is_expected.to validate_presence_of(:confirmation_code) }
    it { is_expected.to validate_uniqueness_of(:confirmation_code) }
  end
end
