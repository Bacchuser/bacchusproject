
# For more information about PRESENTER pattern adopted,
# see [/presenters/presenter.rb]
class AdminTaskPresenter < Presenter
  # http://blog.jayfields.com/2007/03/rails-presenter-pattern.html
  def_delegators :task, :created_at, :updated_at, :label, :is_visible,
                        :created_at=, :updated_at=, :label=, :is_visible=

  def_delegators :admin_task, :description, :is_public,
                              :description=, :is_public=, :id

  def_delegators :admin_user

  # Get the task, create a new if not set.
  def task; @task ||= Task.new end

  # Get the admin_task, create a new if not set.
  def admin_task; @admin_task ||= AdminTask.new end

  # Get the user linked
  def admin_user; @admin_user ||= UserAdmin.new end

  def admin
    if admin_user.nil?
      raise "user is null !"
    end
    admin_user.cake_plan_user
  end

  # Get all the task where the user given is an administrator.
  def self.admin_role(user)
    if user.nil?
      raise "user is null !"
    end

    admin_roles = UserAdmin.find_by_sql ["""
      SELECT admin_tasks.id as admin_task_id,
             user_admins.cake_plan_user_id
      FROM admin_tasks
      INNER JOIN user_admins ON admin_task_id = admin_tasks.id
      WHERE user_admins.cake_plan_user_id = ?
    """, user.id]

    all_tasks_to_admin = []
    admin_roles.each do |admin_role|
      all_tasks_to_admin << self.from_role(admin_role)
    end
    return all_tasks_to_admin
  end

  # Define the presenter for a role (a user and an admin_task)
  # This role can be anything (like admin, oraganisation, see, notification).
  def self.from_role(role)
    presenter = AdminTaskPresenter.new(nil)
    presenter.admin_task = role.task_role
    presenter.admin_user = role.user_role
    return presenter
  end


  # Save the actual task
  def save(update_user)
    Task.transaction do
      if task.new_record? or admin_task.new_record?
        raise "Cannot save before create"
      end

      task.save
      admin_task.save
      log_dependencies
    end
  end

  # Create a new event.
  #   - Add a root in the Task Tree
  #   - Save the data of the Task
  #   - Set the creator as an admin
  def create(creator)
    TaskTree.transaction do
      create_task
      admin_task.task = task
      admin_task.save

      # Assign the admin roles to the creator
      admin_user.admin_task = admin_task
      admin_user.cake_plan_user = creator
      admin_user.save
      log_dependencies
    end
  end

  # Set the admin task and it's parent
  def admin_task=(new_admin_task)
    @admin_task = new_admin_task
    @task = new_admin_task.task
  end

  # Set the admin user of the task
  def admin_user=(new_admin_user)
    @admin_user = new_admin_user
  end

  private
  # Add a new root in the TaskTree
  # Link the task
  def create_task
      task_tree = TaskTree.new
      task_tree.event_id = new_event_id
      task_tree.save

      # link the tree with the task
      task.task_tree = task_tree
      task.save
  end

  # Get the new event id
  def new_event_id
    # create a new event in the task_tree, with a new event id
    temp = TaskTree.order("event_id desc").limit(1).first
    if temp.nil?
      1
    else
      temp.event_id + 1
    end
  end

  def log_dependencies
      Rails.logger.info "--------- log_dependencies"
      Rails.logger.info "# ADMIN TASK PRESENTER INSTANCE"
      Rails.logger.info "task"
      Rails.logger.info task.inspect
      Rails.logger.info "admin task"
      Rails.logger.info admin_task.inspect
      Rails.logger.info "user_admin"
      Rails.logger.info admin_user.inspect
      Rails.logger.info "--------- /log_dependencies"
  end
end