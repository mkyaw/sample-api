class User < ApplicationRecord
  # Assign an API key on create
  before_create do |user|
    user.api_key = generate_api_key
  end

  private
  
  def generate_api_key
    SecureRandom.base64.tr('+/=', 'Qrt')
  end
end
