module Twitter
  module Endpoints
    class CustomToken < ::Grape::API
      helpers Grape::OAuth2::Helpers::OAuthParams

      namespace :oauth do
        params do
          use :oauth_token_params
        end

        post :custom_token do
          token_response = Grape::OAuth2::Generators::Token.generate_for(env) do |request, response|
            # Custom client authentication:
            client = Grape::OAuth2::Strategies::Base.authenticate_client(request)
            request.invalid_client! if client.nil? || client.name != 'Admin'

            resource_owner = Grape::OAuth2::Strategies::Base.authenticate_resource_owner(client, request)
            # request.invalid_grant! if resource_owner.nil?
            request.unauthorized!('invalid id or password') if resource_owner.nil?

            token = AccessToken.create_for(client, resource_owner, request.scope.join(' '))
            response.access_token = Grape::OAuth2::Strategies::Base.expose_to_bearer_token(token)
          end

          status token_response.status

          token_response.headers.each do |key, value|
            header key, value
          end

          body token_response.body
        end
      end
    end
  end
end
