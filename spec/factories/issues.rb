# == Schema Information
#
# Table name: issues
#
#  id          :bigint           not null, primary key
#  description :text             not null
#  name        :string           not null
#  status      :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  project_id  :bigint
#  user_id     :bigint
#
# Indexes
#
#  index_issues_on_project_id  (project_id)
#  index_issues_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :issue do
    
  end
end