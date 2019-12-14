# frozen_string_literal: true

# == Schema Information
#
# Table name: newsletter_subscriptions
#
#  id              :bigint           not null, primary key
#  date_subscribed :date             not null
#  email           :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_newsletter_subscriptions_on_email  (email) UNIQUE
#

# NewsletterSubscription Model
class NewsletterSubscription < ApplicationRecord
  include DateScope

  validates :email,
            uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }

  def self.all_emails
    pluck(:email)
  end

  def self.send_newsletter(newsletter)
    all_emails.each_slice(50) do |emails|
      NewsletterMailer.send_newsletter(emails, newsletter).deliver_later
    end
  end
end
