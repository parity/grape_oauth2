module Grape
  module OAuth2
    # Grape::OAuth2 endpoints namespace
    module Endpoints
      # OAuth2 Grape token endpoint.
      class Token < ::Grape::API
        helpers Grape::OAuth2::Helpers::OAuthParams

        namespace :oauth do
          # @see https://tools.ietf.org/html/rfc6749#section-3.2
          #
          desc 'OAuth 2.0 Token Endpoint (To get access token via password, social_login or refresh_token mechanism)', {
            headers: {"X-Desidime-Client" => {description: "Desidime-Client ID which is required for API access", 
                                             required: true}},
            tags: ['OAuth2']
          }            

          params do
            use :oauth_token_params
          end

          post :token do
            token_response = Grape::OAuth2::Generators::Token.generate_for(env)

            # Status
            status token_response.status

            # Headers
            token_response.headers.each do |key, value|
              header key, value
            end

            # Body
            body token_response.body
          end

          desc 'OAuth 2.0 Token Revocation', {
            hidden: true
          }

          params do
            use :oauth_token_revocation_params
          end

          post :revoke do
            access_token = Grape::OAuth2.config.access_token_class.authenticate(params[:token],
                                                                                type: params[:token_type_hint])

            if access_token
              if access_token.client
                request = Rack::OAuth2::Server::Token::Request.new(env)

                # The authorization server, if applicable, first authenticates the client
                # and checks its ownership of the provided token.
                client = Grape::OAuth2::Strategies::Base.authenticate_client(request)
                request.invalid_client! if client.nil?

                access_token.revoke! if client && client == access_token.client
              else
                # Access token is public
                access_token.revoke!
              end
            end

            # The authorization server responds with HTTP status code 200 if the token
            # has been revoked successfully or if the client submitted an invalid
            # token.
            #
            # @see https://tools.ietf.org/html/rfc7009#section-2.2 Revocation Response
            #
            status 200
            {}
          end
        end
      end
    end
  end
end
