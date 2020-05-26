# frozen_string_literal: true

# == Schema Information
#
# Table name: tasks
#
#  id          :bigint           not null, primary key
#  description :text             default(""), not null
#  name        :string           default(""), not null
#  percentage  :integer          default(0), not null
#  priority    :enum             default("medium"), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  project_id  :bigint
#  user_id     :bigint
#
# Indexes
#
#  index_tasks_on_project_id  (project_id)
#  index_tasks_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#  fk_rails_...  (user_id => users.id)
#

class Task < ApplicationRecord
  enum priority: { high: 'high', medium: 'medium', low: 'low' }

  belongs_to :project
  belongs_to :user

  has_many :task_users, dependent: :destroy
  has_many :users, through: :task_users,
                   before_add: :check_in_project,
                   after_add: :send_assigned_notification,
                   after_remove: :send_removed_notification

  has_many :task_skills, dependent: :destroy
  has_many :skills, through: :task_skills

  validates :name, presence: true
  validates :priority, presence: true
  validates :percentage, presence: true, numericality: { only_integer: true },
                         inclusion: {
                           in: 0..100,
                           message: 'Percentage should be between 0 and 100'
                         }

  after_update_commit :send_update_notification
  after_destroy_commit :destroy_notifications

  def completed?
    percentage == 100
  end

  def send_picked_up_notification
    SendNotificationJob.perform_later([user], notification_params('task/picked'))
  end

  private

  def send_update_notification
    if saved_change_to_percentage? && completed?
      SendNotificationJob.perform_later([user], notification_params('task/completed'))
      users.each do |user|
        Activity.find_or_create_by(key: "task/#{id}", user: user, project: project)
      end
    else
      SendNotificationJob.perform_later(users, notification_params('task/update'))
    end
  end

  def send_assigned_notification(user)
    SendNotificationJob.perform_later([user], notification_params('task/assigned'))
  end

  def send_removed_notification(user)
    SendNotificationJob.perform_later([user], notification_params('task/removed'))
  end

  def destroy_notifications
    Notification.delete_by(notifier: self)
  end

  def notification_params(key)
    { key: key, notifiable: project, notifier: self }
  end

  def check_in_project(record)
    return if record.in_project?(project)

    errors[:base] << 'User is not in project'
    throw(:abort)
  end
end
