class ApplicationController < ActionController::Base
  protect_from_forgery
  require 'vae_static_data'

  def is_administrator?
    unless user_signed_in? and current_user.has_role?('accounts_administrator')
      redirect_to new_user_session_path
    end
  end
end
