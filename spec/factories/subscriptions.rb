FactoryBot.define do
  factory :subscription do
    user { nil }
    plan { nil }
    stripe_subscription_id { "MyString" }
    status { "MyString" }
    current_period_end { "2026-01-01 23:54:42" }
  end
end
