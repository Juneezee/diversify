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
#  user_id    :bigint
#
# Indexes
#
#  index_teams_on_project_id  (project_id)
#  index_teams_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#  fk_rails_...  (user_id => users.id)
#

class Team < ApplicationRecord
    has_many :users
    belongs_to :project

    validates_presence_of :name, :team_size
    validates :team_size, numericality: true, greater_than_or_equal_to: 0
    
    
end