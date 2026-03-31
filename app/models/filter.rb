# frozen_string_literal: true

class Filter < ApplicationRecord
  belongs_to :user
  has_many :expenses, dependent: :nullify

  normalizes :name, with: ->(name) { name&.squish }

  validates :name, presence: true, uniqueness: { scope: :user_id }
end
