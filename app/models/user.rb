# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  admin                  :boolean          default(FALSE)
#  birthdate              :date
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :projects
  has_many :personalities
  has_many :tasks
  has_many :skill_levels
  belongs_to :teams
  belongs_to :reviews
  has_one :preference
  has_one :subscription_plan

  validates_presence_of :email, :admin, :encrypted_password
  validates :email, uniqueness: true, format: {with: URI::MailTo::EMAIL_REGEXP}

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
end
