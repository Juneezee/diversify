# frozen_string_literal: true

require 'rails_helper'

describe UsersController, type: :request do
  let(:user) { create(:user) }
  let!(:admin) { create(:admin) }

  describe 'authorisations' do
    before { sign_in user }

    it { expect { get user_path(user) }.to be_authorized_to(:show?, user) }
    it { expect { get edit_user_path(user) }.to be_authorized_to(:manage?, user) }
    it { expect { patch user_path(user) }.to be_authorized_to(:manage?, user) }
  end

  describe 'GET #show' do
    shared_examples 'shows user profile' do
      it {
        get user_path(user)
        expect(response).to have_http_status(:ok)
      }
    end

    context 'when signed in' do
      before { sign_in user }

      it_behaves_like 'shows user profile'
    end

    context 'when signed out' do
      it_behaves_like 'shows user profile'
    end

    context 'when user does not exist' do
      it 'shows 404' do
        get user_path(id: 0)

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'GET #edit' do
    context 'when signed in' do
      before { sign_in user }

      it 'allows user to edit own profile' do
        get edit_user_path(user)

        expect(response).to have_http_status(:ok)
      end

      it 'does not allow user to edit other user profile' do
        get edit_user_path(admin)

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when signed out' do
      it 'redirects to sign in page' do
        get edit_user_path(user)

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'PATCH #update' do
    before { sign_in user }
    context 'with valid input' do
      it {
        patch user_path(
          id: user.id,
          user: {
            name: user.name,
            birthdate: '1/1/1970'
          }
        )

        expect(response).to have_http_status(:ok)
      }
    end

    context 'with invalid input' do
      it {
        patch user_path(
          'id': user.id,
          user: {
            name: 'name',
            birthdate: '1/1/2020'
          }
        )

        expect(response).to have_http_status(:bad_request)
      }
    end
  end

  describe 'GET #settings' do
    context 'when signed in' do
      before { sign_in user }

      it 'shows user settings page' do
        get settings_users_path

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when signed out' do
      it 'redirects to sign in page' do
        get settings_users_path

        expect(response).to redirect_to new_user_session_path
      end
    end
  end

  describe 'POST #disconnect_omniauth' do
    DeviseHelper::PROVIDERS.keys.each do |social|
      context "with valid #{social} account and no password" do
        let(:omni_user) { create(:omniauth_user, providers: [social]) }

        before { sign_in omni_user }

        it {
          delete disconnect_omniauth_users_path, params: { provider: social }
          follow_redirect!
          expect(response.body).to include('Please set up a password')
        }
      end

      context "with valid #{social} account and password" do
        let(:omni_user) do
          create(:omniauth_user, :has_password, providers: [social])
        end

        before { sign_in omni_user }

        it {
          delete disconnect_omniauth_users_path, params: { provider: social }
          follow_redirect!
          expect(response.body).to include('Account Disconnected')
        }
      end
    end

    context 'with multiple valid social accounts' do
      let(:omni_user) do
        create(:omniauth_user, providers: DeviseHelper::PROVIDERS.keys)
      end

      before { sign_in omni_user }

      it {
        delete disconnect_omniauth_users_path, params: { provider: 'facebook' }
        follow_redirect!
        expect(response.body).to include('Account Disconnected')
      }
    end

    context 'with invalid social account' do
      before { sign_in user }

      it {
        delete disconnect_omniauth_users_path, params: { provider: 'test' }
        follow_redirect!
        expect(response.body).to include('Invalid Request')
      }
    end
  end
end
