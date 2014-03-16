
# For more information about PRESENTER pattern adopted,
# see [/presenters/presenter.rb]
#
# TODO
# [ ] Renaming this : AdminTaskPresenter. Admin reference an ABILITY. Here we have a kind of task
#     so we have to use an other name. Like EventTaskPresenter.
# [ ] Add real exceptions, not raising std Exception with messages !
class EventPresenter < Presenter
  # http://blog.jayfields.com/2007/03/rails-presenter-pattern.html
  def_delegators :task, :created_at, :updated_at, :label, :is_visible,
                        :created_at=, :updated_at=, :label=, :is_visible=

  def_delegators :event, :description, :is_public,
                              :description=, :is_public=, :id, :start_at, :start_at=,
                              :end_at, :end_at=

  def_delegators :admin_user

  include ActiveModel::Validations

  # The validatings are over the model validation.
  # We can this way have a strict insertion model,
  # with a double check (in presenter first, and then in
  # model).
  validates :label, :presence => true
  validates :start_at, :presence => true
  validates :end_at, :presence => true

  # Get the task, create a new if not set.
  def task; @task ||= Task.new end

  # Get the event, create a new if not set.
  def event; @event ||= Event.new end

  # Get the user linked
  def admin_user; @admin_user ||= UserAdmin.new end

  def admin
    if admin_user.nil?
      raise "user is null !"
    end
    admin_user.cake_plan_user
  end

  #
  # Get all the task where the user given is an administrator.
  #
  def self.admin_role(user)
    # Go and search for the different admin roles
    # the user has. Then from the tree we will be able to look for
    # the event data.
    admin_roles = UserAdmin.find_by_sql ["""
      SELECT user_admins.task_tree_id,
             user_admins.cake_plan_user_id
      FROM user_admins
      WHERE user_admins.cake_plan_user_id = ?
    """, user.id]
    all_tasks_to_admin = []
    admin_roles.each do |admin_role|
      all_tasks_to_admin << self.from_role(admin_role)
    end

    return all_tasks_to_admin
  end

  # Define the presenter for a role (a user and an event)
  # This role can be anything (like admin, oraganisation, see, notification).
  def self.from_role(role)
    presenter = EventPresenter.new(nil)
    # TODO use the traditional ORM to find the good event.

    # From the role, we can find the Event task associate,
    # and the particular data of the subclass.
    presenter.event = (Event.find_by_sql ["""
      SELECT events.id,
        events.task_id,
        events.start_at,
        events.end_at,
        events.description,
        events.is_public,
        events.created_at,
        events.updated_at
      FROM events
      INNER JOIN tasks ON events.task_id = tasks.id
      WHERE tasks.task_tree_id = ?
      LIMIT 1
    """, role.task_role]).first
    presenter.admin_user = role.user_role

    return presenter
  end


  # Save the actual task
  def save(update_user)
    if task.new_record? or event.new_record?
      raise "Cannot save before create"
    end

    return false unless valid?
    # We update, so we don't touch the task tree.
    # It's why we do a transaction over Task and not
    # TaskTree.
    Task.transaction do
      task.save
      event.save
      log_dependencies
    end
  end

  # Create a new event.
  #   - Add a root in the Task Tree
  #   - Save the data of the Task
  #   - Set the creator as an admin
  def create(creator)
    if not task.new_record? or not event.new_record?
      raise "Object already exists !"
    end

    return false unless valid?
    # do all the savings routine.
    # If anything will go wrong, transaction
    # will rollback.
    TaskTree.transaction do
      create_task
      event.task = task
      event.save

      # Assign the admin roles to the creator
      admin_user.task_tree = task.task_tree
      admin_user.cake_plan_user = creator
      admin_user.save
      log_dependencies
    end
  end

  # Set the admin task and it's parent
  def event=(new_event)
    @event = new_event
    @task = new_event.task
  end

  # Set the admin user of the task
  def admin_user=(new_admin_user)
    @admin_user = new_admin_user
  end

  private

  # Add a new root in the TaskTree
  # Link the task
  def create_task
      task_tree = TaskTree.new_root
      task_tree.save

      # link the tree with the task
      task.task_tree = task_tree
      task.save
  end


  def log_dependencies
      Rails.logger.info "--------- log_dependencies"
      Rails.logger.info "# ADMIN TASK PRESENTER INSTANCE"
      Rails.logger.info "task"
      Rails.logger.info task.inspect
      Rails.logger.info "event"
      Rails.logger.info event.inspect
      Rails.logger.info "user_admin"
      Rails.logger.info admin_user.inspect
      Rails.logger.info "--------- /log_dependencies"
  end
end