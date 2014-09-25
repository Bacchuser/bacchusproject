
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

  def_delegators :event,  :id, :description, :is_public, :start_at, :end_at,
                 :label, :city, :street, :country, :longitude, :latitude,
                 :label=, :description=, :is_public=, :city=, :street=,
                 :country=, :longitude=, :latitude=,
                 :start_at=, :end_at=

  def_delegators :admin_user

  include ActiveModel::Validations

  # The validatings are over the model validation.
  # We can this way have a strict insertion model,
  # with a double check (in presenter first, and then in
  # model).
  validates :label, :presence => true
  validates :start_at, :presence => true
  validates :end_at, :presence => true
  validates :longitude, :presence => true
  validates :latitude, :presence => true

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
    admin_roles = UserAdmin.where("cake_plan_user_id = :user_id", {user_id: user.id} )
    all_tasks_to_admin = []
    admin_roles.each do |admin_role|
      all_tasks_to_admin << self.from_role(admin_role)
    end

    return all_tasks_to_admin
  end

  # Define the presenter for a role (a user and an event)
  # This role can be anything (like admin, oraganisation, see, notification).
  def self.from_role(role)
    raise "Role is null !" if role.nil?
    raise "Role's user is null !" if role.user_role.nil?
    raise "Role's task is null !" if role.task_role.nil?
    presenter = EventPresenter.new(nil)

    # From the role, we can find the Event task associate,
    # and the particular data of the subclass.
    presenter.event = Event.where("task_id = :task_id", { task_id: role.task.id } ).limit(1).first
    presenter.admin_user = role.user_role
    return presenter
  end


  # Save the actual task
  def save(update_user)
    raise "Cannot save before create" if task.new_record? or event.new_record?
    return false unless valid?

    # We update, so we don't touch the task tree.
    # It's why we do a transaction over Task and not
    # TaskTree.
    Task.transaction do
      task.save!
      event.save!
      log_dependencies
    end
  end

  # Create a new event.
  #   - Add a root in the Task Tree
  #   - Save the data of the Task
  #   - Set the creator as an admin
  def create(creator)
    raise "Object already exists !" if not task.new_record? or not event.new_record?
    return false unless valid?

    # do all the savings routine.
    # If anything will go wrong, transaction
    # will rollback.
    Task.transaction do
      event.save!
      task.root_for_event! (event)
      task.save!
      event.task = task
      event.save!

      # Assign the admin roles to the creator
      admin_user.task = task
      admin_user.cake_plan_user = creator
      admin_user.save!
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