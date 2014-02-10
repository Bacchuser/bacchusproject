class CreateCakePlanUsers < ActiveRecord::Migration
  def change
    create_table :cake_plan_users do |t|
      t.integer :user_id
      t.string :username
      t.string   :email,                  default: "", null: false
      t.string   :encrypted_password,     default: "", null: false
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.integer  :sign_in_count,          default: 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip
      t.string   :password_salt
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email
      t.integer  :failed_attempts,        default: 0
      t.string   :unlock_token
      t.datetime :locked_at
      t.string   :authentication_token
      t.datetime :created_at
      t.datetime :updated_at
      t.timestamps
    end
  end
end
