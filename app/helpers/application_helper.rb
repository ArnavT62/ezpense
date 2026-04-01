# frozen_string_literal: true

module ApplicationHelper
  include ActionView::Helpers::NumberHelper
  def month_options_for_select(year)
    today = Time.zone.today
    last_month =
      if year < today.year
        12
      elsif year == today.year
        today.month
      else
        1
      end
    (1..last_month).map { |m| [Date::MONTHNAMES[m], m] }
  end

  def expenses_path_for_period(year, month)
    expenses_path(year: year, month: month)
  end

  def shift_month(year, month, delta)
    d = Date.new(year, month, 1) >> delta
    [d.year, d.month]
  end

  def previous_period_available?(year, month)
    py, = shift_month(year, month, -1)
    py >= Expense::MIN_SELECTABLE_YEAR
  end

  def next_period_available?(year, month)
    ny, nm = shift_month(year, month, 1)
    today = Time.zone.today
    next_first = Date.new(ny, nm, 1)
    current_first = Date.new(today.year, today.month, 1)
    next_first <= current_first
  end
end
