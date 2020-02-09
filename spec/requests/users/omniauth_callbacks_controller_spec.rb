# frozen_string_literal: true

require 'rails_helper'

describe Users::OmniauthCallbacksController, type: :request do
  let(:user) { create(:user) }

  OmniAuth.config.test_mode = true

  Devise.omniauth_providers.each do |provider|
    before do
      Rails.application.env_config['devise.mapping'] = Devise.mappings[:user]
      Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[provider]
    end

    describe "sign in with #{provider}" do
      context 'with valid account' do
        before { hash(provider) }

        it {
          post "/users/auth/#{provider}/callback"
          expect(response).to redirect_to(root_path)
        }
      end

      context 'with taken email' do
        let(:test_user) { create(:omniauth_user, providers: ['test']) }

        before { hash(provider, test_user.email) }

        it {
          post "/users/auth/#{provider}/callback"
          expect(response).to redirect_to(new_user_registration_path)
        }
      end
    end

    describe "connect with #{provider}" do
      before { sign_in user }

      context 'with valid account' do
        before { hash(provider) }

        it {
          post "/users/auth/#{provider}/callback"
          follow_redirect!
          expect(response.body).to include('Account Connected')
        }
      end

      context 'with taken account' do
        let(:omni_user) { create(:omniauth_user, providers: [provider]) }

        before { hash(provider, omni_user.email) }

        it {
          post "/users/auth/#{provider}/callback"
          follow_redirect!
          expect(response.body).to include('Account has been taken')
        }
      end
    end
  end
end
