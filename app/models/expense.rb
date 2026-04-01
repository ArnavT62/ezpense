# frozen_string_literal: true

class Expense < ApplicationRecord
  MIN_SELECTABLE_YEAR = 2025

  belongs_to :user
  belongs_to :filter, optional: true

  validates :name, presence: true
  validates :spent_on, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validate :spent_on_not_in_future_month
  validate :filter_belongs_to_same_user, if: :filter_id?

  scope :for_month, ->(year, month) {
    start_date = Date.new(year, month, 1)
    end_date = start_date.end_of_month
    where(spent_on: start_date..end_date)
  }

  # First day of calendar month through today (inclusive), capped at month end. Empty if month is entirely in the future.
  scope :for_month_to_date, ->(year, month) {
    start_date = Date.new(year, month, 1)
    today = Time.zone.today
    if start_date > today
      none
    else
      end_date = [start_date.end_of_month, today].min
      where(spent_on: start_date..end_date)
    end
  }

  private

  def spent_on_not_in_future_month
    return if spent_on.blank?

    today = Time.zone.today
    if spent_on.year > today.year || (spent_on.year == today.year && spent_on.month > today.month)
      errors.add(:spent_on, "cannot be in a future month")
    end
  end

  def filter_belongs_to_same_user
    return if filter.blank?
    return if filter.user_id == user_id

    errors.add(:filter, "must belong to the same account")
  end
end
