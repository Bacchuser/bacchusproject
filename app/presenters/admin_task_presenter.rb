
# For more information about PRESENTER pattern adopted,
# see [/presenters/presenter.rb]
class AdminTaskPresenter < Presenter

  # http://blog.jayfields.com/2007/03/rails-presenter-pattern.html
  def_delegators :task, :created_at, :updated_at, :label, :is_visible,
                        :created_at=, :updated_at=, :label=, :is_visible=

  def_delegators :admin_task, :description, :is_public,
                              :description=, :is_public=, :id

  # Get the task, create a new if not set.
  def task; @task ||= Task.new end

  # Get the admin_task, create a new if not set.
  def admin_task; @admin_task ||= AdminTask.new end

  # Set the admin_task presented.
  # Guaranty coherence with task by setting
  # all the presented instances.
  def admin_task=(admin_task)
    @admin_task = admin_task
    @task = @admin_task.task
  end

  # Get all the admin task existing
  def self.all; self.from_admin_tasks(AdminTask.all) end

  def self.from_admin_task(admin_task)
    presenter = AdminTaskPresenter.new(nil)
    presenter.admin_task = admin_task
    return presenter
  end

  def self.from_admin_tasks(admin_tasks)
    all_tasks = []
    admin_tasks.each do | admin_task |
      all_tasks << self.from_admin_task(admin_task)
    end
    return all_tasks
  end

  def save
    TaskTree.transaction do
      # create a new event in the task_tree, with a new event id
      temp = TaskTree.order("event_id desc").limit(1).first
      new_event_id = if temp.nil?
        1
      else
        temp.event_id
      end

      task_tree = TaskTree.new
      task_tree.event_id = new_event_id

      task.task_tree = task_tree
      task.save

      admin_task.task = task
      admin_task.save
    end
  end
end