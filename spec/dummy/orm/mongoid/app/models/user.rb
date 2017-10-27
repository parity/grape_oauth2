class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :login, type: String
  field :password, type: String

  def self.oauth_authenticate(_client, login, password)
    find_by(login: login, password: password)
  end
end
