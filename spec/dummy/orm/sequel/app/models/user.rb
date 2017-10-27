class User < ApplicationRecord
  set_dataset :users
  plugin :secure_password, include_validations: false

  def self.oauth_authenticate(_client, login, password)
    user = find(login: login)
    return if user.nil?

    user.authenticate(password)
  end
end
