# frozen_string_literal: true

class SendMonthlyExpenseReportsJob < ApplicationJob
  queue_as :default

  def perform
    anchor = RecurringReportAnchor.today
    report_date = anchor.beginning_of_month - 1.day
    User.find_each do |user|
      MonthlyReportMailer.monthly_summary(user, report_date.year, report_date.month).deliver_later
    end
  end
end
