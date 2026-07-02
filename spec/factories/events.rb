FactoryBot.define do
  factory :event do
    venue
    name { "Evening Safari" }
    description { "A guided evening tour through Serengeti Park." }
  end
end
