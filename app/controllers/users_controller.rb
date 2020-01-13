# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[show edit update destroy]
  respond_to :js
  before_action :authenticate_user!

  def show; end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    user = User.find(params[:id])
  end
end
