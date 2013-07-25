class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable
  validates_presence_of :username
  validates_uniqueness_of :username

  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :email, :password, :password_confirmation, :remember_me, :authentication_token,
                  :first_name, :last_name, :company, :registered
  attr_accessible :username, :email, :password, :password_confirmation, :remember_me, :authentication_token,
                  :first_name, :last_name, :company, :registered, :role_ids, :as => :admin

  # Relationships
  has_one :account, :dependent => :destroy
  has_many :devices
  has_and_belongs_to_many :roles
  accepts_nested_attributes_for :account
  after_create :create_account
  before_save :setup_role

  def role?(role)
    return !!self.roles.find_by_name(role.to_s.camelize)
  end

  def setup_role
    if self.role_ids.empty?
      self.role_ids = [3]
    end
  end

  def add_role_id(role_id)
    if self.role_ids.empty?
      self.role_ids = [role_id]
    else
      self.role_ids = self.role_ids | [role_id]
    end
  end

  def self.find_or_create_by_android_id(android_id)
    device = Device.find_or_create_by_uuid(android_id)
    if device.user_id.nil?
      u = User.find_or_create_by_username(android_id)
      device.user = u
      device.description = "Android"
      device.save
    end
    return device.user
  end

  def combine_accounts(android_id)
    u = User.find_or_create_by_android_id(android_id)
    device = Device.find_or_create_by_uuid(android_id)

    if device.user.id != self.id

      device.user = self
      device.save

      # Check to see if we should transfer the balance from
      # the old account to the new one.
      if u.devices.empty? && u.username == android_id
        android_balance = u.account.balance
        self_balance = self.account.balance
        if !(android_balance.nil?)
          if self_balance.nil?
            self.account.balance = u.account.balance
          else
            self.account.balance += u.account.balance
          end

          self.save
        end
      end
    end
  end

  # Users will be auto-created whenever a new device uses an application that uses
  # our system.  We will collect their data and progress them through earning
  # balances.  However, when they register, then they will then need a password to
  # be able to access their account.  Registration requires that an email be submitted.
  def password_required?
    if self.email.empty?
      return false
    else
      if (!persisted? || !password.nil? || !password_confirmation.nil?)
        return true
      else
        return false
      end

    end
  end

  def email_required?
    return false
  end

end
