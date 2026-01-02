FactoryBot.define do
  factory :project do
    user { nil }
    url { "MyString" }
    wordpress_api_key { "MyText" }
    wordpress_username { "MyString" }
    name { "MyString" }
    status { "MyString" }
  end
end
