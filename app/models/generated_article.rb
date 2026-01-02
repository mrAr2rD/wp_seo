class GeneratedArticle < ApplicationRecord
  belongs_to :project

  validates :title, presence: true
  validates :content, presence: true
  validates :status, inclusion: { in: %w[pending generating completed failed published] }

  before_validation :set_default_status, on: :create

  scope :pending, -> { where(status: 'pending') }
  scope :completed, -> { where(status: 'completed') }
  scope :published, -> { where(status: 'published') }

  private

  def set_default_status
    self.status ||= 'pending'
  end
end
