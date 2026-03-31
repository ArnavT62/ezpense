# frozen_string_literal: true

class MonthlyReportMailer < ApplicationMailer
  def monthly_summary(user, year, month)
    @user = user
    @year = year
    @month = month
    expenses = user.expenses.for_month(year, month).includes(:filter).order(:spent_on, :id)
    @grand_total = expenses.sum(&:amount)
    @totals_by_filter = expenses
      .group_by { |e| e.filter&.name || "Uncategorized" }
      .transform_values { |xs| xs.sum(&:amount) }

    start_date = Date.new(year, month, 1)
    period_end = start_date.end_of_month
    period_caption = "#{start_date.strftime('%-d %b %Y')} - #{period_end.strftime('%-d %b %Y')}"
    @period_description = period_caption

    pdf = MonthlyReportPdfBuilder.new(
      user: user,
      year: year,
      month: month,
      expenses: expenses,
      grand_total: @grand_total,
      totals_by_filter: @totals_by_filter,
      period_caption: period_caption
    ).render

    attachments["ezpense-report-#{year}-#{month.to_s.rjust(2, '0')}.pdf"] = pdf

    mail to: user.email, subject: "Ezpense — #{Date::MONTHNAMES[month]} #{year} report"
  end

  def month_to_date_summary(user, year, month)
    @user = user
    @year = year
    @month = month
    start_date = Date.new(year, month, 1)
    today = Time.zone.today

    expenses = user.expenses.for_month_to_date(year, month).includes(:filter).order(:spent_on, :id)
    @grand_total = expenses.sum(&:amount)
    @totals_by_filter = expenses
      .group_by { |e| e.filter&.name || "Uncategorized" }
      .transform_values { |xs| xs.sum(&:amount) }

    period_caption, @period_description = month_to_date_period_copy(start_date, today)

    pdf = MonthlyReportPdfBuilder.new(
      user: user,
      year: year,
      month: month,
      expenses: expenses,
      grand_total: @grand_total,
      totals_by_filter: @totals_by_filter,
      period_caption: period_caption
    ).render

    attachments["ezpense-month-to-date-#{year}-#{month.to_s.rjust(2, '0')}.pdf"] = pdf

    mail to: user.email,
      subject: "Ezpense — #{Date::MONTHNAMES[month]} #{year} (month to date)",
      template_name: "monthly_summary"
  end

  private

  def month_to_date_period_copy(start_date, today)
    if start_date > today
      caption = "#{Date::MONTHNAMES[start_date.month]} #{start_date.year} (not started yet)"
      return [caption, "This calendar month has not started yet; no expenses included."]
    end

    period_end = [start_date.end_of_month, today].min
    caption = "#{start_date.strftime('%-d %b %Y')} - #{period_end.strftime('%-d %b %Y')}"
    [caption, "Expenses from #{caption}."]
  end
end
