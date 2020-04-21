# frozen_string_literal: true

# == Schema Information
#
# Table name: tasks
#
#  id          :bigint           not null, primary key
#  description :text             default(""), not null
#  name        :string           default(""), not null
#  percentage  :integer          default(0), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  project_id  :bigint
#  skills_id   :bigint
#  users_id    :bigint
#
# Indexes
#
#  index_tasks_on_project_id  (project_id)
#  index_tasks_on_skills_id   (skills_id)
#  index_tasks_on_users_id    (users_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#  fk_rails_...  (skills_id => skills.id)
#

class Task < ApplicationRecord
  belongs_to :project

  has_many :task_users, dependent: :destroy
  has_many :users, through: :task_users
  has_many :task_skills, dependent: :destroy
  has_many :skills, through: :task_skills

  validates :name, presence: true
  validates :percentage, presence: true, numericality: { only_integer: true },
    inclusion: { in: 0..100, message: 'Percentage should be between 0 and 100'}

  def completed?
    percentage
  end
end
