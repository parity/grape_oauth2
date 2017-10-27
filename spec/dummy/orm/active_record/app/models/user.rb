class User < ApplicationRecord
  has_secure_password

  def self.oauth_authenticate(_client, login, password)
    user = find_by(login: login)
    return if user.nil?

    user.authenticate(password)
  end
end
