module Grape
  module OAuth2
    module Helpers
      # Grape Helper object for OAuth2 requests params.
      # Used fin default Grape::OAuth2 gem endpoints and can be used
      # for custom one.
      module OAuthParams
        extend ::Grape::API::Helpers

        # Params are optional in order to process them correctly in accordance
        # with the RFC 6749 (invalid_client, unsupported_grant_type, etc.)
        params :oauth_token_params do
          requires :grant_type, type: String, desc: 'Grant type', values: ['password', 'refresh_token', 'social_login']
          requires :client_id, type: String, desc: 'Client ID'
          requires :client_secret, type: String, desc: 'Client secret'
          optional :refresh_token, type: String, desc: 'Refresh Token'
          optional :login, type: String, desc: 'Login (Login id or email). Only for grant_type password'          
          optional :password, type: String, desc: 'Password of user. Only for grant_type password'
          optional :email, type: String, desc: 'Email of user as per Social API. Only for grant_type social_login'
          optional :provider, type: String, desc: 'Provider. Only for grant_type social_login', values: ['facebook', 'open_id']
          optional :uid, type: String, desc: 'UID provided by provider. Only for grant_type social_login'
          optional :social_access_token, type: String, desc: 'Social Access Token provided by provider. Only for grant_type social_login'
          
        end

        # Params for authorization request.
        # @see https://tools.ietf.org/html/draft-ietf-oauth-v2-22#section-4.1.1 Authorization Request
        params :oauth_authorization_params do
          optional :response_type, type: String, desc: 'Response type'
          optional :client_id, type: String, desc: 'Client ID'
          optional :redirect_uri, type: String, desc: 'Redirect URI'
          optional :scope, type: String, desc: 'Authorization scopes'
          optional :state, type: String, desc: 'State'
        end

        # Params for token revocation.
        # @see https://tools.ietf.org/html/rfc7009#section-2.1 OAuth 2.0 Token Revocation
        params :oauth_token_revocation_params do
          requires :token, type: String, desc: 'The token that the client wants to get revoked'
          optional :token_type_hint, type: String,
                                     values: %w(access_token refresh_token),
                                     default: 'access_token',
                                     desc: 'A hint about the type of the token submitted for revocation'
        end
      end
    end
  end
end
