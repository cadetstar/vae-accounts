class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation, :remember_me
  attr_accessible :first_name, :last_name, :email, :password, :password_confirmation, :remember_me, :roles, :roles_mask, :as => :administrator

  ROLES = %w(survey_administrator survey_email_administrator careers_administrator careers_hr_administrator accounts_administrator)

  def self.list_for_select
    User.order("last_name, first_name").all.collect{|u| [u, u.id]}
  end

  def self.with_role(role)
    User.where(['roles_mask & ? > 0', 2**ROLES.index(role.to_s)]).all
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
