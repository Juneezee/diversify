# frozen_string_literal: true

require 'rails_helper'

describe 'Team > View team detail', :js, type: :system do
  let(:user) { create(:user) }
  let(:category) { create(:category) }
  let(:project) { create(:project, user: user, category_id: category.id) }

  before do
    create(:team, project_id: project.id)
    sign_in user
    visit "projects/#{project.id}"
  end

  context 'when view team member detail' do
    it do
      find(:xpath, "//p[@class='card-header-title']/span").click
      expect(page).to have_content('Members: 0 / 5', wait: 15)
    end
  end
end
