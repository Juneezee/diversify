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

# Ahoy Event model
class Ahoy::Event < ApplicationRecord
  include Ahoy::QueryMethods
  include DateScope

  self.table_name = 'ahoy_events'

  scope :subscriptions, -> { where(name: 'Clicked pricing link') }
  scope :action, -> { where(name: 'Ran action') }
  scope :social, -> { where(name: 'Click Social') }

  belongs_to :visit
  belongs_to :user, optional: true
end
