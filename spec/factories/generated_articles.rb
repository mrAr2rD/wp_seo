FactoryBot.define do
  factory :generated_article do
    project { nil }
    title { "MyString" }
    content { "MyText" }
    status { "MyString" }
    gemini_prompt { "MyText" }
    published_at { "2026-01-02 09:16:12" }
    wordpress_post_id { "MyString" }
  end
end
