class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :projects, dependent: :destroy
  has_one :subscription, dependent: :destroy

  # Validations
  validates :name, presence: true, allow_blank: true

  # Callbacks
  before_create :generate_jti

  private

  def generate_jti
    self.jti ||= SecureRandom.uuid
  end
end
