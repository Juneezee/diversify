# frozen_string_literal: true

# Controller for landing pages
class PagesController < ApplicationController
  layout 'landing_page'
  skip_authorization_check

  # Function to track subscriptions
  # should be changed once proper subscription system has been completed
  def newsletter
    return unless valid_subscription_type?

    ahoy.track 'Clicked pricing link', type: params[:type]
  end

  def track_social
    return head :bad_request unless valid_social_type?

    ahoy.track 'Click Social', type: params[:type]
    head :ok
  end

  # Function to track time spent in a page
  def track_time
    return head :bad_request unless valid_request?

    ahoy.track 'Time Spent',
               time_spent: millisec_to_sec(params[:time]),
               pathname: params[:pathname]
    head :ok
  end

  def submit_feedback
    if LandingFeedback.new(feedback_params).save
      render json: { message: 'Thank you for your feedback' }
    else
      render json: { message: 'Submission Failed' }, status: 422
    end
  end

  private

  def millisec_to_sec(time)
    time.to_f.round / 1000
  end

  def valid_request?
    params.require(%i[time pathname]) &&
      valid_pathname?(params[:pathname])
  end

  def valid_pathname?(pathname)
    pathname.present? &&
      !pathname.include?('metrics') &&
      !pathname.include?('newsletters')
  end

  def valid_subscription_type?
    %w[Free Pro Enterprise].include? params[:type]
  end

  def valid_social_type?
    %w[Facebook Twitter Email].include? params[:type]
  end

  def feedback_params
    params.require(:landing_feedback).permit(%i[smiley channel interest])
  end
end
