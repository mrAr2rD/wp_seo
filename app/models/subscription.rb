class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :plan

  # Validations
  validates :status, inclusion: { in: %w[active canceled past_due trialing incomplete] }
  validates :stripe_subscription_id, uniqueness: true, allow_nil: true

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :trialing, -> { where(status: 'trialing') }

  # Callbacks
  before_validation :set_default_status, on: :create

  def active?
    status == 'active' || status == 'trialing'
  end

  def expired?
    current_period_end && current_period_end < Time.current
  end

  private

  def set_default_status
    self.status ||= 'trialing'
  end
end
