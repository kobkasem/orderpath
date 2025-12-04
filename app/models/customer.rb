require 'securerandom'

class Customer < ApplicationRecord
  has_many :orders, dependent: :destroy
  
  validates :name, presence: true
  validates :api_key, presence: true, uniqueness: true
  validates :api_endpoint, presence: true
  
  before_validation :generate_api_key, on: :create
  
  def validate_api_endpoint
    # Basic URL validation
    uri = URI.parse(api_endpoint)
    uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
  rescue URI::InvalidURIError
    false
  end
  
  private
  
  def generate_api_key
    self.api_key ||= SecureRandom.hex(32)
  end
end

