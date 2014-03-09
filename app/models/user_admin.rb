class UserAdmin < ActiveRecord::Base
  include Role

  belongs_to :admin_task, dependent: :destroy
  belongs_to :cake_plan_user, dependent: :destroy

  def user_role
    cake_plan_user
  end

  def task_role
    admin_task
  end

  def to_s
    return "admin_task_id = %s, cake_plan_user_id = %s" % [
      admin_task.nil? ? "null" : admin_task.id.to_s,
      cake_plan_user.nil? ? "null" : cake_plan_user.id.to_s]
  end
end
