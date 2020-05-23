# frozen_string_literal: true

# == Schema Information
#
# Table name: newsletter_subscriptions
#
#  id         :bigint           not null, primary key
#  email      :string           not null
#  subscribed :boolean          default(TRUE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_newsletter_subscriptions_on_email  (email) UNIQUE
#

class NewsletterSubscription < ApplicationRecord
  has_many :newsletter_feedbacks, dependent: :nullify

  validates :email,
            presence: true,
            uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }

  scope :all_subscribed_emails, -> { where(subscribed: true).pluck(:email) }
  scope :previously_subscribed, -> { where(subscribed: false) }
  scope :subscribed_count, -> { all_subscribed_emails.size }

  after_commit :send_welcome, on: :create

  def self.subscribe(email)
    record = where(email: email).first_or_initialize

    record.update(subscribed: true) if record.new_record? || (record.persisted? && !record.subscribed?)
  end

  def unsubscribe
    return true unless subscribed?

    update_columns(subscribed: false) # rubocop:disable Rails/SkipsModelValidations
  end

  private

  def send_welcome
    NewsletterMailer.send_welcome(email).deliver_later
  end
end
