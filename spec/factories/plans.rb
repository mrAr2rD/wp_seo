FactoryBot.define do
  factory :plan do
    name { "MyString" }
    price { "9.99" }
    features { "" }
    stripe_price_id { "MyString" }
    max_projects { 1 }
    max_articles { 1 }
  end
end
