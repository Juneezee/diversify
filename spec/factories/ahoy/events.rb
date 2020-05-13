# frozen_string_literal: true

# == Schema Information
#
# Table name: ahoy_events
#
#  id         :bigint           not null, primary key
#  name       :string
#  properties :jsonb
#  time       :datetime
#  user_id    :bigint
#  visit_id   :bigint
#
# Indexes
#
#  index_ahoy_events_on_name_and_time  (name,time)
#  index_ahoy_events_on_properties     (properties) USING gin
#  index_ahoy_events_on_user_id        (user_id)
#  index_ahoy_events_on_visit_id       (visit_id)
#

FactoryBot.define do
  factory :ahoy_event, class: Ahoy::Event.name do
    association :visit, factory: :ahoy_visit

    trait :ran_action do
      name { 'Ran action' }
      properties { { action: 'home', controller: 'pages' } }
    end

    trait :time_spent do
      name { 'Time Spent' }
      properties { { pathname: '/', time_spent: '4' } }
    end

    # Social share traits
    trait :social_share do
      name { 'Click Social' }
    end

    trait :facebook do
      social_share
      properties { { type: 'Facebook' } }
    end

    trait :twitter do
      social_share
      properties { { type: 'Twitter' } }
    end

    trait :email do
      social_share
      properties { { type: 'Email' } }
    end

    time { Time.current }
  end
end
