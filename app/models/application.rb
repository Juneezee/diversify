# frozen_string_literal: true

# == Schema Information
#
# Table name: applications
#
#  id         :bigint           not null, primary key
#  types      :enum             default("Invite"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  project_id :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_applications_on_project_id  (project_id)
#  index_applications_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#  fk_rails_...  (user_id => users.id)
#
class Application < ApplicationRecord
  belongs_to :project
  belongs_to :user

  validates :types, uniqueness: { scope: %i[project_id user_id] }
end
