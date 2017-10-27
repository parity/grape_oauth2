require 'spec_helper'

describe 'Token Endpoint' do
  let(:application) { Application.create(name: 'App1') }
  let(:user) { User.create(login: 'test', password: '12345678') }

  describe 'Resource Owner Password Credentials flow' do
    describe 'POST /oauth/token' do
      let(:authentication_url) { '/api/v1/oauth/token' }

      context 'with valid params' do
        context 'when request is invalid' do
          it 'fails without Grant Type' do
            post authentication_url,
                 login: user.login,
                 password: '12345678',
                 client_id: application.key,
                 client_secret: application.secret

            expect(AccessToken.all).to be_empty

            expect(json_body[:error]).to eq('invalid_request')
            expect(last_response.status).to eq 400
          end

          it 'fails with invalid Grant Type' do
            post authentication_url,
                 grant_type: 'invalid',
                 login: user.login,
                 password: '12345678'

            expect(AccessToken.all).to be_empty

            expect(json_body[:error]).to eq('unsupported_grant_type')
            expect(last_response.status).to eq 400
          end

          it 'fails without Client Credentials' do
            post authentication_url,
                 grant_type: 'password',
                 login: user.login,
                 password: '12345678'

            expect(AccessToken.all).to be_empty

            expect(json_body[:error]).to eq('invalid_request')
            expect(last_response.status).to eq 400
          end

          it 'fails with invalid Client Credentials' do
            post authentication_url,
                 grant_type: 'password',
                 login: user.login,
                 password: '12345678',
                 client_id: 'blah-blah',
                 client_secret: application.secret

            expect(AccessToken.all).to be_empty

            expect(json_body[:error]).to eq('invalid_client')
            expect(last_response.status).to eq 401
          end

          it 'fails without Resource Owner credentials' do
            post authentication_url,
                 grant_type: 'password',
                 client_id: application.key,
                 client_secret: application.secret

            expect(json_body[:error]).to eq('invalid_request')
            expect(json_body[:error_description]).not_to be_blank
            expect(last_response.status).to eq 400
          end

          it 'fails with invalid Resource Owner credentials' do
            post authentication_url,
                 grant_type: 'password',
                 login: 'invalid@example.com',
                 password: 'invalid',
                 client_id: application.key,
                 client_secret: application.secret

            expect(json_body[:error]).to eq('invalid_grant')
            expect(json_body[:error_description]).not_to be_blank
            expect(last_response.status).to eq 400
          end
        end

        context 'with valid data' do
          context 'when scopes requested' do
            it 'returns an Access Token with scopes' do
              post authentication_url,
                   grant_type: 'password',
                   login: user.login,
                   password: '12345678',
                   scope: 'read write',
                   client_id: application.key,
                   client_secret: application.secret

              expect(AccessToken.count).to eq 1
              expect(AccessToken.first.client_id).to eq application.id

              expect(json_body[:access_token]).to be_present
              expect(json_body[:token_type]).to eq 'bearer'
              expect(json_body[:expires_in]).to eq 7200
              expect(json_body[:refresh_token]).to be_nil
              expect(json_body[:scope]).to eq('read write')

              expect(last_response.status).to eq 200
            end
          end

          context 'without scopes' do
            it 'returns an Access Token without scopes' do
              post authentication_url,
                   grant_type: 'password',
                   login: user.login,
                   password: '12345678',
                   client_id: application.key,
                   client_secret: application.secret

              expect(AccessToken.count).to eq 1
              expect(AccessToken.first.client_id).to eq application.id

              expect(json_body[:access_token]).to be_present
              expect(json_body[:token_type]).to eq 'bearer'
              expect(json_body[:expires_in]).to eq 7200
              expect(json_body[:refresh_token]).to be_nil
              expect(json_body[:scope]).to be_nil

              expect(last_response.status).to eq 200
            end
          end
        end

        context 'when Token endpoint not mounted' do
          before do
            Twitter::API.reset!
            Twitter::API.change!

            # Mount only Authorization Endpoint
            Twitter::API.send(:include, Grape::OAuth2.api(:authorize))
          end

          after do
            Twitter::API.reset!
            Twitter::API.change!

            Twitter::API.send(:include, Grape::OAuth2.api)
            Twitter::API.mount(Twitter::Endpoints::Status)
            Twitter::API.mount(Twitter::Endpoints::CustomToken)
            Twitter::API.mount(Twitter::Endpoints::CustomAuthorization)
          end

          it 'returns 404' do
            post authentication_url,
                 grant_type: 'password',
                 login: user.login,
                 password: '12345678',
                 client_id: application.key,
                 client_secret: application.secret

            expect(last_response.status).to eq 404
          end
        end
      end
    end
  end

  describe 'POST /oauth/custom_token' do
    context 'when block processed successfully' do
      it 'returns an access token' do
        application.update(name: 'Admin')

        post '/api/v1/oauth/custom_token',
             grant_type: 'password',
             login: user.login,
             password: '12345678',
             client_id: application.key,
             client_secret: application.secret

        expect(last_response.status).to eq 200

        expect(AccessToken.count).to eq 1
        expect(AccessToken.first.client_id).to eq application.id

        expect(json_body[:access_token]).to be_present
        expect(json_body[:token_type]).to eq 'bearer'
        expect(json_body[:expires_in]).to eq 7200
      end
    end

    context 'when authentication failed' do
      it 'returns an error' do
        application.update(name: 'Admin')

        post '/api/v1/oauth/custom_token',
             grant_type: 'password',
             login: 'invalid@example.com',
             password: 'invalid',
             client_id: application.key,
             client_secret: application.secret

        expect(json_body[:error]).to eq('invalid_grant')
        expect(json_body[:error_description]).not_to be_blank
        expect(last_response.status).to eq 400
      end
    end
  end
end
