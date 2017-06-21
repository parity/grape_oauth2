module Grape
  module OAuth2
    # Grape::OAuth2 endpoints namespace
    module Endpoints
      # OAuth2 Grape authorization endpoint.
      class Authorize < ::Grape::API
        helpers Grape::OAuth2::Helpers::OAuthParams

        namespace :oauth do
          desc 'OAuth 2.0 Authorization Endpoint', {
            hidden: true
          }

          params do
            use :oauth_authorization_params
          end

          post :authorize do
            response = Grape::OAuth2::Generators::Authorization.generate_for(env)

            # Status
            status response.status

            # Headers
            response.headers.each do |key, value|
              header key, value
            end

            # Body
            body response.body
          end
        end
      end
    end
  end
end
