# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  # everyone can see any post
  def show?
    true
  end

  def edit?
    user.id == record.id
  end
end
