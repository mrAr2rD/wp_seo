class ArticleGenerationWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform(article_id)
    article = GeneratedArticle.find(article_id)
    article.update(status: 'generating')

    gemini_service = GeminiService.new

    # Extract keywords from prompt if available
    keywords = extract_keywords(article.gemini_prompt)

    # Generate article content
    content = gemini_service.generate_article(
      article.title,
      keywords: keywords,
      word_count: 1000
    )

    if content.present?
      article.update(
        content: content,
        status: 'completed'
      )
    else
      article.update(status: 'failed')
    end
  rescue StandardError => e
    Rails.logger.error("Article generation failed: #{e.message}")
    article.update(status: 'failed') if article
    raise e
  end

  private

  def extract_keywords(prompt)
    return [] unless prompt.present?

    # Simple keyword extraction - in production, use more sophisticated approach
    prompt.split(',').map(&:strip).reject(&:blank?)
  end
end
