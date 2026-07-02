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
end
