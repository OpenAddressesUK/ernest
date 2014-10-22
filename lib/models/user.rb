class User < ActiveRecord::Base
  has_many :addresses
  before_create :generate_key

  private

    def generate_key
      self.api_key = SecureRandom.hex
    end
end
