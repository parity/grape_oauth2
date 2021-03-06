module Grape
  module OAuth2
    # Grape::OAuth2 strategies namespace
    module Strategies
      # Base Grape::OAuth2 Strategies class .
      # Contains common functionality for all the descendants.
      class Base
        class << self
          # Authenticates Client from the request.
          def authenticate_client(request)
            config.client_class.authenticate(request.client_id, request.try(:client_secret))
          end

          # Authenticates Resource Owner from the request.
          def authenticate_resource_owner(client, request)
            config.resource_owner_class.oauth_authenticate(client, request.login, request.password)
          end
          
          # Authenticates Resource Owner from the request via Social Login.
          def authenticate_resource_owner_social(client, request)
            config.resource_owner_class.oauth_authenticate_social(client, request.email, request.provider, request.uid, request.social_access_token)
          end

          # Short getter for Grape::OAuth2 configuration
          def config
            Grape::OAuth2.config
          end

          # Converts scopes from the request string. Separate them by the whitespace.
          # @return [String] scopes string
          #
          def scopes_from(request)
            return nil if request.scope.nil?

            Array(request.scope).join(' ')
          end

          # Exposes token object to Bearer token.
          #
          # @param token [#to_bearer_token]
          #   any object that responds to `to_bearer_token`
          # @return [Rack::OAuth2::AccessToken::Bearer]
          #   bearer token instance
          #
          def expose_to_bearer_token(token)
            Rack::OAuth2::AccessToken::Bearer.new(token.to_bearer_token)
          end
        end
      end
    end
  end
end
