class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation, :remember_me
  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation, :remember_me, :roles, :roles_mask, :as => :administrator

  ROLES = %w(survey_administrator survey_email_administrator careers_administrator careers_hr_administrator accounts_administrator)

  def self.bounce_authentication(username, crypted_password)
    unless user = User.find_for_authentication(:email => username)
      return nil
    end
    password = crypted_password
    user.valid_password?(password) ? user : nil
  end

  def self.list_for_select
    User.order("last_name, first_name").all.collect{|u| [u, u.id]}
  end

  def self.with_role(role)
    User.where(['roles_mask & ? > 0', 2**ROLES.index(role.to_s)]).all
  end

  def passkey
    "#{id}-#{current_sign_in_at}-#{current_sign_in_ip}"
  end

  def encoded_passkey
    require 'openssl'
    require 'digest'
    require 'digest/sha1'

    public_key_file  = 'lib/keys/acct_remote.pem'

    f = File.read(public_key_file)

    public_key = OpenSSL::PKey::RSA.new(f)

    Base64.encode64(public_key.public_encrypt(passkey))
  end

  def attributes_for_remote
    t = attributes
    t.reject!{|k,v| k == 'roles_mask'}
    t['roles'] = roles
    t
  end

  def roles=(roles)
    self.roles_mask = (roles & ROLES).map {|r| 2**ROLES.index(r)}.sum
  end

  def roles
    ROLES.reject{ |r| ((roles_mask || 0) & 2**ROLES.index(r)).zero?}
  end

  def has_role?(role)
    self.roles.include?(role.to_s)
  end

  def enabled
    !self.inactive?
  end

  def enabled=(val)
    self.inactive = !val
  end

  def active_for_authentication?
    self.enabled
  end

  def inactive_message
    "Your account is not active.  Please contact #{VaeStaticData::ADMINS[:primary][:name]}."
  end

  def name_std
    [first_name, last_name].compact.join(' ')
  end

  def to_s
    if first_name.blank? and last_name.blank?
      email
    else
      name_std
    end
  end
end
