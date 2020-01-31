# frozen_string_literal: true

# Controller for profile and settings
class UsersController < ApplicationController
  helper DeviseHelper
  before_action :set_user, only: %i[show edit update]
  respond_to :js

  layout 'devise'

  def show
    authorize! @user
  end

  def edit
    authorize! @user
  end

  def update; end

  def settings; end

  def unsubscribe_omniauth
    return unless request.xhr?

    if last_social_account?
      render json: { errors:
        ['Please set up a password before disabling all Social Accounts'] },
             status: :bad_request
    else
      Identity.destroy_by(user: current_user, provider: params[:provider])
      flash[:toast] = { type: 'success', message: ['Account Disconnected'] }
      render js: "window.location='#{settings_users_path}'"
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  def last_social_account?
    Identity.where(user: current_user).count <= 1 &&
      current_user.encrypted_password.blank?
  end
end
