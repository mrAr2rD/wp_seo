class Plan < ApplicationRecord
  has_many :subscriptions

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stripe_price_id, presence: true
  validates :max_projects, presence: true, numericality: { greater_than: 0 }
  validates :max_articles, presence: true, numericality: { greater_than: 0 }

  # Scopes
  scope :active, -> { where(active: true) }
end
