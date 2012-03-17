class DepartmentsController < ApplicationController
  before_filter :is_administrator?
  before_filter :find_department, :only => [:edit, :update, :destroy]
  def index
    @departments = Department.order([:code, :name])
  end

  def new
    @department = Department.create
    redirect_to edit_department_path(@department)
  end

  def edit
  end

  def update
    @department.update_attributes(params[:department])
    flash[:notice] = 'Department updated.'
    redirect_to departments_path
  end

  def destroy
    flash[:notice] = @department.destroy
    redirect_to departments_path
  end

  def find_department
    unless @department = Department.find_by_id(params[:id])
      flash[:alert] = 'That department could not be found.'
      redirect_to departments_path
    end
  end
end