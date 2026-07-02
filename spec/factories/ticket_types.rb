FactoryBot.define do
  factory :ticket_type do
    event
    name { "Adult" }
    price_cents { 2_500 }
    capacity { 10 }
  end
end
