# == Schema Information
#
# Table name: projects
#
#  id          :bigint           not null, primary key
#  description :text             default(""), not null
#  name        :string           default(""), not null
#  status      :string           default("active"), not null
#  visibility  :string           default("public"), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :bigint
#
# Indexes
#
#  index_projects_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class Project < ApplicationRecord
    belongs_to :user
    belongs_to :category
    has_many :teams
    has_many :reviews
    has_many :tasks

    validates_presence_of :name, :status, :visibility
end