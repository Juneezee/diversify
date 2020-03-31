# frozen_string_literal: true

# Base class for application policies
class ApplicationPolicy < ActionPolicy::Base
  authorize :user, allow_nil: true

  # Configure additional authorization contexts here
  # (`user` is added by default).
  #
  #   authorize :account, optional: true
  #
  # Read more about authoriztion context: https://actionpolicy.evilmartians.io/#/authorization_context

  # private

  # Define shared methods useful for most policies.
  # For example:
  #
  def owner?
    record.user == user
  end
end
