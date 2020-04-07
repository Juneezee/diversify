# frozen_string_literal: true

# Controller for applications/invites for projects
class InvitesController < ApplicationController
  before_action :prepare_accept, only: :accept

  def create
    find_user
    @invite = Invite.new(invite_params)

    return invite_fail('Invalid Request') unless allowed_to?(:create?, @invite)

    @invite.save ? invite_success : invite_fail(nil)
  end

  def destroy
    @invite = Invite.find_by(invite_params)

    return invite_fail('Invalid Request') if @invite.blank?
    return invite_fail('Invalid Request') unless allowed_to?(:destroy?, @invite)

    @invite.destroy ? destroy_success : invite_fail(nil)
  end

  def accept
    return invite_fail('Invalid Request') unless allowed_to?(:accept?, @invite)

    @team.users << @invite.user
    if @team.save
      @invite.send_accept_notification
      @invite.destroy
      accept_success
    else
      invite_fail('There is a problem joining project')
    end
  end

  private

  def prepare_accept
    @invite = Invite.find_by(invite_params)
    return invite_fail('Invalid Request') if @invite.blank?

    @team = @invite.project.teams.find_by(name: 'Unassigned')
  end

  def invite_params
    params.except(:_method, :authenticity_token)
          .permit(:id, :user_id, :project_id, :types)
  end

  def invite_success
    if params[:types] == 'Invite'
      render json: {
        message: 'Invite Sent', invite_id: @invite.id,
        email: @invite.user.email, id: @invite.user_id
      }, status: :ok
    else
      flash[:toast_success] = 'Application Sent'
      render js: "window.location = '#{project_path(@invite.project.id)}'"
    end
  end

  def accept_success
    if current_user == @invite.user
      flash[:toast_success] = 'Joined Project'
      render js: "window.location = '#{project_path(@invite.project.id)}'"
    else
      render json: {}, status: :ok
    end
  end

  def decline?
    (@invite.user == current_user && @invite.types == 'Invite') ||
      (@invite.types == 'Application' && @invite.user != current_user)
  end

  def destroy_notification
    if decline?
      @invite.notify :user, key: "decline.#{@invite.types.downcase}",
                            parameters: { default: @invite.project },
                            notifier: @invite.project
    else
      ActivityNotification::Notification
        .find_by(notifiable_type: 'Invite', notifiable_id: @invite.id)&.destroy
    end
  end

  def destroy_success
    destroy_notification
    if @invite.managed?(current_user)
      render json: {}, status: :ok
    else
      flash[:toast_success] = "#{@invite.types} Canceled"
      render js: "window.location = '#{project_path(@invite.project)}'"
    end
  end

  def invite_fail(message)
    message ||= @invite.errors.full_messages
    render json: { message: message },
           status: :bad_request
  end

  def find_user
    params[:user_id] =
      User.find_by(email: params[:user_id])&.id
  end
end
