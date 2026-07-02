FactoryBot.define do
  factory :booking_item do
    booking
    ticket_type { association :ticket_type, event: booking.event }
    quantity { 1 }
  end
end
