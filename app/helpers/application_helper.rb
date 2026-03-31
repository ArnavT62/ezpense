# frozen_string_literal: true

module ApplicationHelper
  include ActionView::Helpers::NumberHelper
  def month_options_for_select
    (1..12).map { |m| [Date::MONTHNAMES[m], m] }
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
    ny, = shift_month(year, month, 1)
    ny <= Time.zone.today.year
  end
end
