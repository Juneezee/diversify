# frozen_string_literal: true

# == Schema Information
#
# Table name: task_skills
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  skill_id   :bigint           not null
#  task_id    :bigint           not null
#
# Indexes
#
#  index_task_skills_on_skill_id              (skill_id)
#  index_task_skills_on_skill_id_and_task_id  (skill_id,task_id) UNIQUE
#  index_task_skills_on_task_id               (task_id)
#
# Foreign Keys
#
#  fk_rails_...  (skill_id => skills.id)
#  fk_rails_...  (task_id => tasks.id)
#
FactoryBot.define do
  factory :task_skill do
    association :skill, factory: :skill
    association :task, factory: :task
  end
end
