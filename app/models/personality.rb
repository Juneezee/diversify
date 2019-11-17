# == Schema Information
#
# Table name: personalities
#
#  id              :bigint           not null, primary key
#  trait           :string           default(""), not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  compatible_id   :bigint
#  incompatible_id :bigint
#
# Indexes
#
#  index_personalities_on_compatible_id    (compatible_id)
#  index_personalities_on_incompatible_id  (incompatible_id)
#

class Personality < ApplicationRecord
    belongs_to :users
    has_and_belongs_to_many :personalities

    validates :trait, presence: true, uniqueness: true
end