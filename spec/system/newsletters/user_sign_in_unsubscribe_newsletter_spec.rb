# frozen_string_literal: true

require 'rails_helper'
require_relative 'user_helper'

describe 'Logged in page Newsletter > Subscribe', :js, type: :system do
  let(:user) { create(:user) }

  it 'unsubscribe from settings page' do
    visit settings_profile_path
    fill_form(user.email, user.password)
    click_button 'Sign in'
    click_link 'Emails'
    if find_button('Subscribe Newsletter').visible?
      click_button 'Subscribe Newsletter'
      click_button 'Unsubscribe Newsletter'
    else
      click_button 'Unsubscribe Newsletter'
    end
    expect(page).to have_content('Newsletter Unsubscribed')
  end

end
