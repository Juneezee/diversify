# frozen_string_literal: true

require 'rails_helper'

describe 'Show Notification > Notification', :js, type: :system do
  let(:user) { create(:user) }
  let(:project) { create(:project) }

  before do
    sign_in user
    create(:notification, user: user, key: 'invite/invite', notifier: project)
    visit notifications_path
  end

  context 'when there is notification' do
    it 'notify user' do
      within('.dropdown-trigger') do
        find('.button.is-rounded').click
      end
      expect(page).to have_no_content('No Notifications')
    end

    it 'show notifications' do
      expect(page).to have_no_content('You have 0 New Notifications')
    end

    it 'can open all notifications' do
      click_on 'Open All Notifications'
      expect(page).to have_content('You have 0 New Notifications')
    end

    it 'can open notification' do
      within '#notification' do
        first('a').click
      end
      expect(page).to have_content('Owned by:')
    end
  end
end
