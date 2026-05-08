FactoryBot.define do
  factory :billetto_event do
    sequence(:external_id) { |n| "billetto_#{n}" }
    title       { Faker::Music::RockBand.name + " Live" }
    description { Faker::Lorem.paragraph }
    starts_at   { 1.week.from_now }
    ends_at     { 1.week.from_now + 3.hours }
    location    { Faker::Address.city }
    status      { "published" }
  end
end