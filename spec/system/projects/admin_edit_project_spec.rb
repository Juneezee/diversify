# frozen_string_literal: true

require 'rails_helper'

describe 'Edit Project > Project', :js, type: :system do
  let(:admin) { create(:admin) }
  let(:project) do
    create(:project, :private, user: admin, category: create(:category))
  end

  before do
    sign_in admin
    visit "projects/#{project.id}"
    find('a', text: 'Settings').click
  end

  context 'when project is private' do
    it 'can change to public' do
      find('#project_visibility_true').click
      click_button 'Save changes'
      find('a', text: 'Settings').click
      expect(page).to have_field('project_visibility_true', checked: true)
    end
  end
end
