FactoryBot.define do
  factory :booking do
    event
    booking_date { Date.current }
    sequence(:confirmation_code) { |n| "BOOKING-#{n}" }
  end
end
