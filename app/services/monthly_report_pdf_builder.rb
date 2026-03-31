# frozen_string_literal: true

require "prawn"
Prawn::Fonts::AFM.hide_m17n_warning = true if defined?(Prawn::Fonts::AFM)

class MonthlyReportPdfBuilder
  def initialize(user:, year:, month:, expenses:, grand_total:, totals_by_filter:, period_caption: nil)
    @user = user
    @year = year
    @month = month
    @expenses = expenses
    @grand_total = grand_total
    @totals_by_filter = totals_by_filter.sort_by { |name, _| name }.to_h
    @period_caption = period_caption || "#{Date::MONTHNAMES[@month]} #{@year}"
  end

  def render
    Prawn::Document.new(margin: 48) do |pdf|
      pdf.text "Ezpense - monthly report", size: 18, style: :bold
      pdf.move_down 4
      pdf.text @period_caption.to_s, size: 14
      pdf.move_down 4
      pdf.text @user.email.to_s, size: 10, color: "666666"
      pdf.move_down 24

      pdf.text "Summary by filter", size: 12, style: :bold
      pdf.move_down 8
      if @totals_by_filter.any?
        @totals_by_filter.each do |label, amount|
          pdf.text "#{label}: #{format_money(amount)}", size: 11
          pdf.move_down 4
        end
      else
        pdf.text "No expenses in this period.", size: 11
        pdf.move_down 8
      end
      pdf.move_down 8
      pdf.text "Grand total: #{format_money(@grand_total)}", size: 12, style: :bold
      pdf.move_down 24

      pdf.text "Line items", size: 12, style: :bold
      pdf.move_down 8
      if @expenses.any?
        @expenses.each do |expense|
          line = "#{expense.spent_on} - #{expense.name} - #{format_money(expense.amount)}"
          line += " (#{expense.filter.name})" if expense.filter
          pdf.text line, size: 10
          if expense.description.present?
            pdf.indent(12) do
              pdf.text expense.description.to_s, size: 9, color: "555555"
            end
          end
          pdf.move_down 6
        end
      else
        pdf.text "None.", size: 10
      end
    end.render
  end

  private

  def format_money(value)
    # Prawn built-in fonts are not UTF-8; use "INR" instead of the rupee sign in PDFs.
    "INR #{format('%.2f', value.to_d)}"
  end
end
