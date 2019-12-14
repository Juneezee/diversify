# == Schema Information
#
# Table name: reviews
#
#  id          :bigint           not null, primary key
#  rating      :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  project_id  :bigint
#  reviewee_id :bigint
#  reviewer_id :bigint
#
# Indexes
#
#  index_reviews_on_project_id   (project_id)
#  index_reviews_on_reviewee_id  (reviewee_id)
#  index_reviews_on_reviewer_id  (reviewer_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#  fk_rails_...  (reviewee_id => users.id)
#  fk_rails_...  (reviewer_id => users.id)
#

FactoryBot.define do
  factory :review do
    
  end
end
