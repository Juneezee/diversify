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

require 'rails_helper'

describe Ahoy::Event, type: :model do
  describe 'modules' do
    it { is_expected.to include_module(Ahoy::QueryMethods) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:visit) }
    it { is_expected.to belong_to(:user).optional }
  end

  describe 'scopes' do
    subject(:model) { described_class }

    describe '.action' do
      let(:action_event) { create(:ahoy_event, :ran_action) }

      it { expect(model.action).to include(action_event) }
    end

    describe '.social' do
      let(:social_event) { create(:ahoy_event, :facebook) }

      it { expect(model.social).to include(social_event) }
    end

    describe '.type_size' do
      subject { model.social.type_size }

      let!(:event) { create(:ahoy_event, :facebook) }

      it { is_expected.to eq(event.properties['type'] => 1) }
    end

    describe  '.type_team_size' do
      subject { model.social.type_time_size }

      let!(:event) { create(:ahoy_event, :facebook) }

      it { is_expected.to eq([event.properties['type'], event.time.to_date] => 1) }
    end
  end
end
