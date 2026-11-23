class User < ApplicationRecord
  has_many :trips, dependent: :restrict_with_error
  has_many :participations, dependent: :restrict_with_error
  normalizes :email, with: ->(email) { email.strip.downcase }
  validates :name, :email, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, uniqueness: { case_sensitive: false }
end
