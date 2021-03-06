# frozen_string_literal: true

require 'rails_helper'

describe ProjectsController, type: :request do
  let(:user) { create(:user) }
  let(:project) { create(:project) }

  describe 'authorisations' do
    before { sign_in user }

    describe 'authorized_scope :own' do
      subject(:request) { get projects_path }

      it {
        expect { request }
          .to have_authorized_scope(:active_record_relation)
          .as(:own)
          .with(ProjectPolicy)
      }
    end

    describe 'authorized_scope :joined' do
      subject(:request) { get projects_path, params: { joined: true } }

      it {
        expect { request }
          .to have_authorized_scope(:active_record_relation)
          .as(:joined)
          .with(ProjectPolicy)
      }
    end

    describe 'authorized_scope :explore' do
      subject(:request) { get explore_projects_path }

      it {
        expect { request }
          .to have_authorized_scope(:active_record_relation)
          .as(:explore)
          .with(ProjectPolicy)
      }
    end

    describe '#show' do
      subject(:request) { get project_path(project) }

      it { expect { request }.to be_authorized_to(:show?, project) }
    end

    describe '#update' do
      subject(:request) { patch project_path(project) }

      it { expect { request }.to be_authorized_to(:manage?, project) }
    end

    describe '#change_status' do
      subject(:request) { patch change_status_project_path(project) }

      it { expect { request }.to be_authorized_to(:change_status?, project) }
    end
  end

  describe 'GET #index' do
    subject(:request) { get projects_path }

    it_behaves_like 'accessible to authenticated users'
    it_behaves_like 'not accessible to unauthenticated users'
  end

  describe 'GET #explore' do
    subject(:request) { get explore_projects_path }

    it_behaves_like 'accessible to authenticated users'
    it_behaves_like 'accessible to unauthenticated users'
  end

  describe 'GET #index JSON' do
    subject(:request) { get projects_path(params), xhr: true, headers: { accept: 'application/json' } }

    before { sign_in user }

    context 'with valid params' do
      let(:params) { { name: 'valid', status: 'open' } }

      it_behaves_like 'returns JSON response'
    end

    context 'with invalid page' do
      let(:params) { { page: -1 } }

      it_behaves_like 'returns 404 Not Found'
    end
  end

  describe 'GET #show' do
    subject(:request) { get project_path(project) }

    let(:admin) { create(:admin) }

    context 'with owned public project' do
      let(:project) { create(:project, user: user) }

      it_behaves_like 'accessible to authenticated users'
      it_behaves_like 'accessible to unauthenticated users'
    end

    context 'with not owned public project' do
      let(:project) { create(:project, user: admin) }

      it_behaves_like 'accessible to authenticated users'
      it_behaves_like 'accessible to unauthenticated users'
    end

    context 'with owned private project' do
      let(:user) { create(:user, :pro) }
      let(:project) { create(:project, :private, user: user) }

      it_behaves_like 'accessible to authorised users for public object'
    end

    context 'with not owned private project' do
      let(:project) { create(:project, :private, user: admin) }

      it_behaves_like 'not accessible to unauthorised users for public object'
    end

    context 'with joined private project' do
      let(:project) { create(:project, :private, user: admin) }

      before { project.unassigned_team.users << user }

      it_behaves_like 'accessible to authorised users for public object'
    end
  end

  describe 'GET #new' do
    subject(:request) { get new_project_path }

    it_behaves_like 'accessible to authenticated users'
    it_behaves_like 'not accessible to unauthenticated users'
  end

  describe 'POST #create' do
    subject(:request) { post projects_path(params) }

    let(:category) { create(:category) }

    context 'with valid inputs' do
      let(:params) do
        { project: { name: 'Test', description: 'Test', category_id: category.id } }
      end

      it_behaves_like 'accessible to authenticated users'
      it_behaves_like 'not accessible to unauthenticated users'
    end

    context 'with invalid inputs' do
      let(:params) do
        { project: { name: 'Test', description: 'Test', category_id: 'a' } }
      end

      before { sign_in user }

      it_behaves_like 'returns 422 Unprocessable Entity'
    end

    context 'when set visibility with valid license' do
      let(:user) { create(:user, :pro) }

      let(:params) do
        { project: { name: 'Test', description: 'Test', visibility: false, category_id: category.id } }
      end

      it_behaves_like 'accessible to authenticated users'
    end
  end

  describe 'POST #update' do
    subject(:request) { patch project_path(project), params: params }

    let(:project) { create(:project, user: user) }
    let(:category) { create(:category) }

    context 'with valid inputs' do
      let(:params) do
        {
          project: {
            name: 'Test', description: 'Test', category_id: category.id,
            avatar: fixture_file_upload('spec/fixtures/squirtle.png')
          }
        }
      end

      it_behaves_like 'accessible to authenticated users'
      it_behaves_like 'not accessible to unauthenticated users'
    end

    context 'with invalid inputs' do
      let(:params) do
        {
          project: {
            name: 'Test', description: 'Test', category_id: 'a',
            avatar: fixture_file_upload('spec/fixtures/squirtle.png')
          }
        }
      end

      before { sign_in user }

      it_behaves_like 'returns 422 Unprocessable Entity'
    end

    context 'when set visibility with valid license' do
      let(:user) { create(:user, :pro) }

      let(:params) do
        { project: { name: 'Test', description: 'Test', visibility: 'false', category_id: category.id } }
      end

      it_behaves_like 'accessible to authenticated users'
    end

    context 'when not owner of project' do
      let(:user2) { create(:user) }
      let(:params) do
        { project: { name: 'Test', description: 'Test', category_id: category.id } }
      end

      before { sign_in user2 }

      it_behaves_like 'returns 404 Not Found'
    end
  end

  describe 'PATCH #change_status' do
    subject(:request) { patch change_status_project_path(project, params) }

    %w[open active completed].each do |status|
      context "with valid status change to #{status}" do
        let(:project) { create(:project, user: user) }
        let(:params) { { status: status } }

        it_behaves_like 'accessible to authenticated users'
        it_behaves_like 'not accessible to unauthenticated users'
      end
    end

    context 'with invalid status change' do
      let(:project) { create(:project, user: user, status: 'open') }
      let(:params) { { status: 'completed' } }

      before { sign_in user }

      it_behaves_like 'returns 422 Unprocessable Entity'
    end

    context 'when not project owner' do
      let(:user2) { create(:user) }
      let(:project) { create(:project, user: user, status: 'active') }
      let(:params) { { status: 'open' } }

      before { sign_in user2 }

      it_behaves_like 'returns 404 Not Found'
    end
  end

  describe 'POST #count' do
    subject(:request) { get count_project_path(project, params) }

    let(:project) { create(:project, user: user) }

    %w[task application].each do |type|
      context "with valid query for #{type}" do
        let(:params) { { type: type } }

        it_behaves_like 'accessible to authenticated users'
        it_behaves_like 'not accessible to unauthenticated users'
      end
    end

    context 'with invalid type' do
      let(:params) { { type: 'bla' } }

      before { sign_in user }

      it_behaves_like 'returns 400 Bad Request'
    end
  end
end
