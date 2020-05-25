# frozen_string_literal: true

require 'rails_helper'

describe TaskPolicy, type: :policy do
  let(:user) { build_stubbed(:user) }
  let(:project) { create(:project) }
  let(:record) { build_stubbed(:task, project: project) }

  let(:context) { { user: user } }

  describe 'relation_scope' do
    let(:user) { create(:user) }
    let(:target) { Task.where(name: %w[Test Test2]) }

    before do
      task = create(:task, :completed, name: 'Test', project: project)
      project.unassigned_team.users << user
      task.users << user
      create(:task, name: 'Test2')
    end

    describe ':assigned' do
      subject do
        policy.apply_scope(
          target, type: :active_record_relation, name: :assigned
        ).pluck(:name)
      end

      it { is_expected.to eq(%w[Test]) }
    end

    describe ':unassigned' do
      subject do
        policy.apply_scope(
          target, type: :active_record_relation, name: :unassigned
        ).group('tasks.id').pluck(:name)
      end

      it { is_expected.to eq(%w[Test2]) }
    end

    describe ':active' do
      subject do
        policy.apply_scope(
          target, type: :active_record_relation, name: :active
        ).group('tasks.id').pluck(:name)
      end

      it { is_expected.to eq(%w[Test2]) }
    end

    describe ':completed' do
      subject do
        policy.apply_scope(
          target, type: :active_record_relation, name: :completed
        ).group('tasks.id').pluck(:name)
      end

      before { Task.find_by(name: 'Test').percentage = 100 }

      it { is_expected.to eq(%w[Test]) }
    end
  end

  describe_rule :manage? do
    failed 'when not in project'

    failed 'when not owner' do
      let(:user) { create(:user) }

      before { project.unassigned_team.users << user }
    end

    succeed 'when is task owner' do
      before { record.user = user }
    end

    succeed 'when user is project owner' do
      before { project.user = user }
    end

    succeed 'when user is admin' do
      before { user.admin = true }
    end
  end

  describe_rule :set_percentage? do
    failed 'when not in project'

    failed 'when not owner' do
      let(:user) { create(:user) }

      before { project.unassigned_team.users << user }
    end

    succeed 'when is task owner' do
      before { record.user = user }
    end

    succeed 'when is task assignee' do
      let(:record) { create(:task, project: project) }
      let(:user) { create(:user) }

      before do
        project.unassigned_team.users << user
        record.users << user
      end
    end

    succeed 'when user is project owner' do
      before { project.user = user }
    end

    succeed 'when user is admin' do
      before { user.admin = true }
    end
  end

  describe_rule :assign_self? do
    failed 'when not in project'

    succeed 'when in project' do
      let(:user) { create(:user) }

      before { project.user = user }
    end
  end
end
