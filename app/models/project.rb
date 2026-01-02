class Project < ApplicationRecord
  belongs_to :user
  has_many :generated_articles, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }
  validates :wordpress_api_key, presence: true
  validates :status, inclusion: { in: %w[active inactive pending] }

  # Callbacks
  before_validation :set_default_status, on: :create
  before_save :encrypt_api_key

  # Scopes
  scope :active, -> { where(status: 'active') }

  private

  def set_default_status
    self.status ||= 'pending'
  end

  def encrypt_api_key
    return unless wordpress_api_key_changed?
    # Use Rails encrypted attributes or a similar mechanism
    # For now, we'll use a simple encryption (in production use rails credentials)
    self.wordpress_api_key = Base64.strict_encode64(wordpress_api_key) if wordpress_api_key.present?
  end

  def decrypt_api_key
    Base64.strict_decode64(wordpress_api_key) if wordpress_api_key.present?
  rescue ArgumentError
    wordpress_api_key
  end
end
