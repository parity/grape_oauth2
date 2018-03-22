module Grape
  module OAuth2
    module Strategies
      # Resource Owner Password Credentials strategy class.
      # Processes request and respond with Access Token.
      class SocialLogin < Base
        class << self
          # Processes Password request.
          def process(request)
            client = authenticate_client(request) || request.invalid_client!
            # resource_owner = authenticate_resource_owner_social(client, request)
            response = authenticate_resource_owner(client, request)
            request.unauthorized!('Username or Password is invalid.') if response.blank? 

            # request.invalid_grant! if resource_owner.nil?
            # request.unauthorized!('invalid id or password') if resource_owner.nil?
            if response[:error] || response[:resource_owner].blank?
              error = response[:error_message] || 'Username or Password is invalid.'
              request.unauthorized!(error)
            end

            resource_owner = response[:resource_owner]
            token = config.access_token_class.create_for(client, resource_owner, scopes_from(request))
            expose_to_bearer_token(token)
          end
        end
      end
    end
  end
end
