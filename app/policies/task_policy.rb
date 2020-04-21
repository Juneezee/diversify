# frozen_string_literal: true

# Class for Task policies
class TaskPolicy < ApplicationPolicy
  alias_rule :create?, to: :new?
  default_rule :manage?

  relation_scope do |scope, team_id: nil, project: nil|
    if user&.admin? || project.user == user
      next scope.collect { |s| [s.name, s.id] }
    end

    scope.includes(:teams).where(teams: { id: team_id })
         .collect { |s| [s.name, s.id] }
  end

  relation_scope(:assigned) do |scope|
    scope.left_outer_joins(:task_users).where(task_users: { user_id: user.id })
  end

  relation_scope(:unassigned) do |scope|
    scope.left_outer_joins(:task_users).having("count(task_users) = 0")
  end

  relation_scope(:active) do |scope|
    scope.having("percentage != 100")
  end

  relation_scope(:completed) do |scope|
    scope.having("percentage = 100")
  end

  def new?
    allowed_to? :create_task?, record.project
  end

  def manage?
    owner? || user&.admin? || record.project.user == user
  end

  def set_percentage?
    owner? || user&.admin? || record.project.user == user ||
      record.users.include?(user)
  end
end
