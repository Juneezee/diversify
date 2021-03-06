# frozen_string_literal: true

# == Schema Information
#
# Table name: task_users
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  task_id    :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_task_users_on_task_id              (task_id)
#  index_task_users_on_user_id              (user_id)
#  index_task_users_on_user_id_and_task_id  (user_id,task_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (task_id => tasks.id)
#  fk_rails_...  (user_id => users.id)
#
FactoryBot.define do
  factory :task_user do
    association :user, factory: :user
    association :task, factory: :task
  end
end
