# frozen_string_literal: true

# == Schema Information
#
# Table name: ahoy_visits
#
#  id               :bigint           not null, primary key
#  app_version      :string
#  browser          :string
#  city             :string
#  country          :string
#  device_type      :string
#  ip               :string
#  landing_page     :text
#  latitude         :float
#  longitude        :float
#  os               :string
#  os_version       :string
#  platform         :string
#  referrer         :text
#  referring_domain :string
#  region           :string
#  started_at       :datetime
#  user_agent       :text
#  utm_campaign     :string
#  utm_content      :string
#  utm_medium       :string
#  utm_source       :string
#  utm_term         :string
#  visit_token      :string
#  visitor_token    :string
#  user_id          :bigint
#
# Indexes
#
#  index_ahoy_visits_on_user_id      (user_id)
#  index_ahoy_visits_on_visit_token  (visit_token) UNIQUE
#

FactoryBot.define do
  factory :ahoy_visit, class: Ahoy::Visit.name do
    #sequence(:visit_token) { |n| "#{n}2345678-eeee-cccc-ssss-884d5re" }
  end
end

