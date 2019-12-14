# frozen_string_literal: true

# == Schema Information
#
# Table name: teams
#
#  id         :bigint           not null, primary key
#  name       :string           default(""), not null
#  team_size  :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  project_id :bigint
#
# Indexes
#
#  index_teams_on_project_id  (project_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#

# Team model
class Team < ApplicationRecord
  belongs_to :project
  has_many :users

  validates_presence_of :name, :team_size
  validates :team_size, numericality: { greater_than_or_equal_to: 0 }
end
