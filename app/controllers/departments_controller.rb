class DepartmentsController < ApplicationController
  before_filter :is_administrator?, :except => :remote_request
  before_filter :find_department, :only => [:edit, :update, :destroy]
  def index
    @departments = Department.order([:code, :name])
  end

  def remote_request
    private_key = OpenSSL::PKey::RSA.new(File.read('lib/keys/remote_acct'))
    begin
      key = private_key.private_decrypt(Base64.decode64(params[:key].to_s.gsub(' ','+')))
      if key.to_i == Time.now.at_beginning_of_day.to_i
        k = {}
        k[:departments] = Department.where("code is not null and code != ''").all.collect{|d| [d.code, d.name, d.city, d.state, d.supervising_department.try(:code), d.manager.try(:email), d.supervisor.try(:email), d.classification, d.short_name]}
        k[:users] = User.all.collect{|u| u.attributes_for_remote}
        # Put in user_departments here eventually
        render :text => k.to_json
      else
        render :text => ''
      end
    rescue Exception => e
      puts e.backtrace
      render :text => ''
    end
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