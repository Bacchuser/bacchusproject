class UserAdmin < ActiveRecord::Base
  include Role
  # TODO : change belongs_to to task_tree. We can
  #   be an admin of all the different task, and the
  #   goal of permission tree, is to manage such relation !

  belongs_to :cake_plan_user
  belongs_to :task

  def user_role
    self.cake_plan_user
  end

  def task_role
    self.task
  end
end
