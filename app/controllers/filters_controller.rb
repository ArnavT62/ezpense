# frozen_string_literal: true

class FiltersController < ApplicationController
  before_action :set_filter, only: %i[edit update destroy]

  def index
    @filters = current_user.filters.order(:name)
    @filter = Filter.new
  end

  def create
    @filter = current_user.filters.build(filter_params)
    if @filter.save
      redirect_to filters_path, notice: "Filter added."
    else
      @filters = current_user.filters.order(:name)
      render :index, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @filter.update(filter_params)
      redirect_to filters_path, notice: "Filter updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @filter.destroy
    redirect_to filters_path, notice: "Filter removed."
  end

  private

  def set_filter
    @filter = current_user.filters.find(params[:id])
  end

  def filter_params
    params.require(:filter).permit(:name)
  end
end
