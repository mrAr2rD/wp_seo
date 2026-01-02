class WordpressPublishWorker
  include Sidekiq::Worker
  sidekiq_options retry: 2

  def perform(article_id)
    article = GeneratedArticle.find(article_id)
    project = article.project

    # Decode WordPress API key
    api_key = Base64.strict_decode64(project.wordpress_api_key)

    response = HTTParty.post(
      "#{project.url}/wp-json/wp/v2/posts",
      headers: {
        'Authorization' => "Basic #{Base64.strict_encode64(api_key)}",
        'Content-Type' => 'application/json'
      },
      body: {
        title: article.title,
        content: article.content,
        status: 'draft' # Publish as draft for review
      }.to_json
    )

    if response.success?
      wordpress_post = JSON.parse(response.body)
      article.update(
        status: 'published',
        published_at: Time.current,
        wordpress_post_id: wordpress_post['id'].to_s
      )
    else
      Rails.logger.error("WordPress publish failed: #{response.code} - #{response.body}")
      raise "Failed to publish to WordPress: #{response.message}"
    end
  rescue StandardError => e
    Rails.logger.error("WordPress publish error: #{e.message}")
    raise e
  end
end
