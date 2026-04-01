# frozen_string_literal: true

class ExpensesController < ApplicationController
  before_action :set_expense, only: %i[edit update destroy]
  before_action :set_period, only: %i[index mail_month_to_date]

  def index
    @expenses = current_user.expenses
      .for_month(@year, @month)
      .includes(:filter)
      .order(spent_on: :desc, id: :desc)
    @grand_total = @expenses.sum(&:amount)
    @totals_by_filter = @expenses
      .group_by { |e| e.filter&.name || "Uncategorized" }
      .transform_values { |list| list.sum(&:amount) }
      .sort_by { |name, _| name }
      .to_h
    @year_options = year_options_for(current_user)
  end

  def new
    @expense = current_user.expenses.build(spent_on: Time.zone.today)
  end

  def create
    @expense = current_user.expenses.build(expense_params)
    if @expense.save
      redirect_to expenses_path(year: @expense.spent_on.year, month: @expense.spent_on.month),
        notice: "Expense added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @expense.update(expense_params)
      redirect_to expenses_path(year: @expense.spent_on.year, month: @expense.spent_on.month),
        notice: "Expense updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    y = @expense.spent_on.year
    m = @expense.spent_on.month
    @expense.destroy
    redirect_to expenses_path(year: y, month: m), notice: "Expense removed."
  end

  def mail_month_to_date
    MonthlyReportMailer.month_to_date_summary(current_user, @year, @month).deliver_later
    redirect_to expenses_path(year: @year, month: @month),
      notice: "Report for #{Date::MONTHNAMES[@month]} #{@year} is on its way to your inbox."
  end

  private

  def set_expense
    @expense = current_user.expenses.find(params[:id])
  end

  def set_period
    @year = parse_year_param
    @month = parse_month_param
  end

  def parse_year_param
    current = Time.zone.today.year
    y = params[:year].presence&.to_i
    return current if y.nil?

    [[y, Expense::MIN_SELECTABLE_YEAR].max, current].min
  end

  def parse_month_param
    m = params[:month].presence&.to_i
    m = Time.zone.today.month if m.nil? || m < 1 || m > 12
    [m, max_month_for_year(@year)].min
  end

  def max_month_for_year(year)
    today = Time.zone.today
    return 12 if year < today.year
    return today.month if year == today.year

    1
  end

  def expense_params
    p = params.require(:expense).permit(:name, :description, :amount, :spent_on, :filter_id)
    p[:filter_id] = nil if p[:filter_id].blank?
    p
  end

  def year_options_for(_user)
    current = Time.zone.today.year
    (Expense::MIN_SELECTABLE_YEAR..current).to_a
  end
end
