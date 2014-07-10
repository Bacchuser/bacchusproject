class CreateInvitations < ActiveRecord::Migration
  def change
    create_table :invitations do |t|
      t.integer :task_id
      t.integer :cake_plan_user_id
      t.integer :status, default: -1
      t.datetime :valid_at
      t.timestamps
    end
  end
end
