class ApplicationController < ActionController::Base
  protect_from_forgery
  require 'vae_static_data'

  def set_return_to
    session[:user_return_to] = params[:return_to]
    if !user_signed_in? and user = User.bounce_authentication(params[:username], params[:password])
      sign_in(:user, user)
    end
    if current_user
      redirect_to session[:user_return_to] + "?user=#{current_user.id}&key=#{current_user.encoded_passkey}"
    else
      redirect_to session[:user_return_to]
    end
  end

  def validate_passkey
    require 'digest'
    require 'base64'
    require 'openssl'
    if user = User.find_by_id(params[:id])
      private_key = OpenSSL::PKey::RSA.new(File.read('lib/keys/remote_acct'))
      key = private_key.private_decrypt(Base64.decode64(params[:key].gsub(' ','+')))
      if key == user.passkey
        render :text => user.attributes_for_remote.to_json
      else
        render :text => "invalid"
      end
    else
      render :text => "invalid"
    end
  end

  def is_administrator?
    unless user_signed_in? and current_user.has_role?('accounts_administrator')
      redirect_to new_user_session_path
    end
  end
end
