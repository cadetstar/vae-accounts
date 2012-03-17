class Users::RegistrationsController < Devise::RegistrationsController
  before_filter :is_administrator?, :except => [:edit, :update]
  before_filter :authenticate_user!, :only => [:edit, :update]
  before_filter :find_user, :only => [:admin_edit, :admin_update, :enable, :destroy]
  skip_before_filter :require_no_authentication


  def create
    build_resource

    if resource.save
      flash[:notice] = "User created."
      redirect_to users_path
    else
      flash[:error] = "User failed to save."
      redirect_to new_user_registration_path
    end
  end

  def index
    @users = User.order("inactive, email")
  end

  def admin_edit
  end

  def admin_update
    if params[:user][:password].blank?
      params[:user].reject!{|k,v| k.to_s =~ /password/}
    end
    @user.update_attributes(params[:user], :as => :administrator)
    flash[:notice] = 'User updated'
    redirect_to users_path
  end

  def enable
    # Reenables the user
    if @user.enabled
      flash[:notice] = "#{@user} is already enabled."
    else
      @user.update_attribute(:inactive, false)
      flash[:notice] = "#{@user} is now enabled."
    end
    redirect_to users_path
  end

  def destroy
    # Deactivates the user
    if @user.enabled
      @user.update_attribute(:inactive, true)
      flash[:notice] = "#{@user} is now disabled."
    else
      flash[:notice] = "#{@user} is already disabled."
    end
    redirect_to users_path
  end

  def find_user
    unless @user = User.find(params[:id])
      flash[:alert] = "I could not find a user with that ID."
      redirect_to users_path
    end
  end
end