class UserAdmin < ActiveRecord::Base
  include Role
  # TODO : change belongs_to to task_tree. We can
  #   be an admin of all the different task, and the
  #   goal of permission tree, is to manage such relation !

  belongs_to :cake_plan_user, dependent: :destroy
  belongs_to :task_tree, dependent: :destroy

  def user_role
    cake_plan_user
  end

  def task_role
    task_tree
  end
end
