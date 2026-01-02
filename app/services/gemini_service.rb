class GeminiService
  include HTTParty
  base_uri 'https://generativelanguage.googleapis.com'

  def initialize
    @api_key = ENV.fetch('GEMINI_API_KEY', 'your_gemini_api_key_here')
  end

  def generate_article(topic, keywords: [], word_count: 1000)
    prompt = build_prompt(topic, keywords, word_count)

    response = self.class.post(
      "/v1beta/models/gemini-pro:generateContent?key=#{@api_key}",
      headers: { 'Content-Type' => 'application/json' },
      body: {
        contents: [
          {
            parts: [
              { text: prompt }
            ]
          }
        ],
        generationConfig: {
          temperature: 0.7,
          maxOutputTokens: 2048
        }
      }.to_json
    )

    if response.success?
      extract_content(response)
    else
      raise "Gemini API error: #{response.code} - #{response.message}"
    end
  end

  private

  def build_prompt(topic, keywords, word_count)
    keywords_text = keywords.any? ? "Keywords to include: #{keywords.join(', ')}" : ""

    <<~PROMPT
      Write a comprehensive, SEO-optimized blog post in HTML format about: #{topic}

      #{keywords_text}
      Target word count: approximately #{word_count} words

      Requirements:
      1. Use proper HTML tags (h1, h2, h3, p, ul, ol, li, strong, em)
      2. Create an engaging introduction with a hook
      3. Break content into clear sections with descriptive headings
      4. Include practical examples and actionable advice
      5. Add a compelling conclusion with a call-to-action
      6. Naturally incorporate the keywords throughout the content
      7. Write in a conversational yet professional tone
      8. Make it valuable and informative for readers

      Return ONLY the HTML content without any markdown code blocks or explanations.
    PROMPT
  end

  def extract_content(response)
    parsed = JSON.parse(response.body)
    candidates = parsed.dig('candidates')

    return nil unless candidates&.any?

    content = candidates.first.dig('content', 'parts', 0, 'text')
    clean_html_content(content)
  end

  def clean_html_content(content)
    return nil unless content

    # Remove markdown code blocks if present
    content = content.gsub(/```html\n?/, '').gsub(/```\n?/, '')

    # Ensure content is wrapped in proper tags
    content.strip
  end
end
