# == Schema Information
#
# Table name: user_personalities
#
#  id             :bigint           not null, primary key
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  personality_id :bigint
#  user_id        :bigint
#
# Indexes
#
#  index_user_personalities_on_personality_id  (personality_id)
#  index_user_personalities_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (personality_id => personalities.id)
#  fk_rails_...  (user_id => users.id)
#

FactoryBot.define do
  factory :user_personality do
  end
end
