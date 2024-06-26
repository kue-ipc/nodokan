class DeviseCreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      ## Database authenticatable
      t.string :username,           null: false, index: {unique: true}
      t.string :email,              null: false
      t.string :fullname
      # t.string :encrypted_password, null: false, default: ""

      t.integer :role,    null: false, default: 0, limit: 1
      t.boolean :deleted, null: false, default: false

      ## Recoverable
      # t.string   :reset_password_token
      # t.datetime :reset_password_sent_at

      ## Rememberable
      # t.datetime :remember_created_at

      ## Trackable
      # t.integer  :sign_in_count, default: 0, null: false
      # t.datetime :current_sign_in_at
      # t.datetime :last_sign_in_at
      # t.inet     :current_sign_in_ip
      # t.inet     :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # Only if lock strategy is :failed_attempts
      t.integer  :failed_attempts, default: 0, null: false
      # Only if unlock strategy is :email or :both
      t.string   :unlock_token, index: {unique: true}
      t.datetime :locked_at

      # for count
      t.integer :nodes_count, null: false, default: 0
      t.integer :assignments_count, null: false, default: 0

      t.timestamps null: false
    end

    # add_index :users, :username,             unique: true
    # add_index :users, :email,                unique: true
    # add_index :users, :reset_password_token, unique: true
    # add_index :users, :confirmation_token,   unique: true
    # add_index :users, :unlock_token,         unique: true
  end
end
