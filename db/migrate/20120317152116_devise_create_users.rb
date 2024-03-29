class DeviseCreateUsers < ActiveRecord::Migration
  def self.up
    create_table(:users) do |t|
      t.database_authenticatable :null => false
      t.recoverable
      t.rememberable
      t.trackable

      # t.encryptable
      # t.confirmable
      # t.lockable :lock_strategy => :failed_attempts, :unlock_strategy => :both
      # t.token_authenticatable


      t.string    :first_name
      t.string    :last_name
      t.boolean   :inactive, :default => false
      t.integer   :roles_mask

      t.timestamps

    end

    add_index :users, :email,                :unique => true
    add_index :users, :reset_password_token, :unique => true
    # add_index :users, :confirmation_token,   :unique => true
    # add_index :users, :unlock_token,         :unique => true
    # add_index :users, :authentication_token, :unique => true

    u = User.create(:email => 'admin@vaecorp.com', :password => 'vaecorp', :password_confirmation => 'vaecorp')
    u.roles = ["accounts_administrator"]
    u.save
  end

  def self.down
    drop_table :users
  end
end
