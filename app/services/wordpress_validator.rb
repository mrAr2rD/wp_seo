class WordpressValidator
  attr_reader :project, :error_message

  def initialize(project)
    @project = project
    @error_message = nil
  end

  def valid?
    return false unless project.url.present? && project.wordpress_api_key.present?

    begin
      response = HTTParty.get(
        "#{project.url}/wp-json/wp/v2/posts",
        headers: {
          'Authorization' => "Basic #{encode_credentials}"
        },
        timeout: 10
      )

      if response.success?
        true
      else
        @error_message = "WordPress API returned error: #{response.code}"
        false
      end
    rescue HTTParty::Error, SocketError, Timeout::Error => e
      @error_message = "Failed to connect to WordPress: #{e.message}"
      false
    end
  end

  private

  def encode_credentials
    # Decode the stored encrypted key first
    api_key = Base64.strict_decode64(project.wordpress_api_key)
    credentials = "#{project.wordpress_username}:#{api_key}"
    Base64.strict_encode64(credentials)
  rescue ArgumentError
    # If decoding fails, use the key as-is
    credentials = "#{project.wordpress_username}:#{project.wordpress_api_key}"
    Base64.strict_encode64(credentials)
  end
end
