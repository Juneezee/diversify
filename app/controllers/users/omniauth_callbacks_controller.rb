# frozen_string_literal: true

# controller for OAuth Devise
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  before_action :from_omniauth, only: %i[google_oauth2 twitter facebook]

  def google_oauth2
    if @user.persisted?
      user_signed_in? ? connect_success_action : sign_in_success_action
    else
      fail_action
    end
  end

  def twitter
    if @user.persisted?
      user_signed_in? ? connect_success_action : sign_in_success_action
    else
      session['devise.twitter_data'] = request.env['omniauth.auth']
      fail_action
    end
  end

  def facebook
    if @user.persisted?
      user_signed_in? ? connect_success_action : sign_in_success_action
    else
      session['devise.facebook_data'] = request.env['omniauth.auth']
      fail_action
    end
  end

  # More info at:
  # https://github.com/plataformatec/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  # protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end

  private

  def from_omniauth
    identity = User.from_omniauth(request.env['omniauth.auth'], current_user)

    return @user = identity.user if identity.errors.blank?

    flash[:toast] = { type: 'error', message: identity.errors.full_messages }
    redirect_to settings_users_path
  end

  def connect_success_action
    flash[:toast] = { type: 'success', message: ['Account Connected'] }
    redirect_to settings_users_path
  end

  def sign_in_success_action
    sign_in @user
    redirect_to after_sign_in_path_for(@user)
  end

  def fail_action
    flash[:toast] = { type: 'error', message: @user.errors.full_messages }
    redirect_to new_user_registration_url
  end
end
