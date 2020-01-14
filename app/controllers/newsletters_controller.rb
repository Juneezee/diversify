# frozen_string_literal: true

# Controller for newsletter
class NewslettersController < ApplicationController
  layout 'metrics_page'
  before_action :authenticate_user!, except: %i[subscribe unsubscribe post_unsubscribe]

  def index
    @newsletters = Newsletter.all.decorate
  end

  def create
    newsletter = Newsletter.new(newsletter_params)

    if newsletter.save
      flash[:toast] = { type: 'success', message: 'Newsletter sent' }
      render js: "window.location='#{newsletter_path(newsletter)}'"
    else
      render json: { message: 'Send Failed' }, status: :unprocessable_entity
    end
  end

  def show
    @newsletter = Newsletter.find(params[:id])

    return unless request.xhr?

    render json: {
      html: render_to_string('newsletters/_modal.haml', layout: false)
    }
  end

  def subscribers
    @subscribers = NewsletterSubscription.where(subscribed: true).decorate
  end

  def subscribe
    sub_fail_action('No Email') if params[:email].blank?

    email = params[:email]
    if NewsletterSubscription.previously_subscribed.exists?(email: email)
      sub = NewsletterSubscription.find_by(email: email)
      sub.subscribed = true
    else
      sub = NewsletterSubscription.new(email: email, subscribed: true)
    end
    sub.save ? sub_pass_action : sub_fail_action('Subscription Failed')
  end

  def self_subscribe
    email = current_user.email
    if NewsletterSubscription.previously_subscribed.exists?(email: email)
      sub = NewsletterSubscription.find_by(email: email)
      sub.subscribed = true
    else
      sub = NewsletterSubscription.new(email: email, subscribed: true)
    end
    if sub.save
      render js: "window.location='#{settings_users_path}'"
    else
      sub_fail_action('Subscription Failed')
    end
  end

  def unsubscribe
    render layout: false
  end

  def self_unsubscribe
    newsletter_subscription = NewsletterSubscription.where(email: current_user.email).first
    newsletter_subscription.update(subscribed: false)
    redirect_to settings_users_path
  end

  def post_unsubscribe
    feedback = NewsletterFeedback.create(unsubscribe_params)

    if feedback.errors.any?
      render json: { message: feedback.errors.full_messages.join(', ') },
             status: :unprocessable_entity
    else
      # Prevent Oracle attack on newsletter subscribers list by returning as
      # long as the params syntax are correct
      render json: { message: 'Newsletter Unsubscribed! Hope to see you again' }
    end
  end

  private

  def newsletter_params
    params.require(:newsletter).permit(:title, :content)
  end

  def unsubscribe_params
    p = params.require(:newsletter_unsubscription).permit(:email, reasons: [])

    {
      newsletter_subscription: NewsletterSubscription.find_by(email: p[:email]),
      reasons: p[:reasons]
    }
  end

  def sub_pass_action
    render json: { message: 'Thanks for subscribing' }
  end

  def sub_fail_action(message)
    render json: { message: message }, status: :unprocessable_entity
  end
end
