
# For more information about PRESENTER pattern adopted,
# see [/presenters/presenter.rb]
class AdminTaskPresenter < Presenter

  # http://blog.jayfields.com/2007/03/rails-presenter-pattern.html
  def_delegators :task, :created_at, :updated_at, :label, :is_visible,
                        :created_at=, :updated_at=, :label=, :is_visible=
  def_delegators :admin_task, :description, :is_public,
                              :description=, :is_public=, :id

  def task
    @task ||= Task.new
  end

  def admin_task
    @admin_task ||= AdminTask.new
  end

  def find(param)
    @admin_task = AdminTask.find(param)
    @task = @admin_task.task
  end

  def task=(value)
    @task = value
  end

  def admin_task=(value)
    @admin_task = value
  end

  def self.all
    all_tasks = []
    AdminTask.all.each do | admin_task |
      presenter = AdminTaskPresenter.new(nil)
      presenter.task = admin_task.task
      presenter.admin_task = admin_task
      all_tasks << presenter
    end
    return all_tasks
  end

  def save
    Task.transaction do
      task.save
      admin_task.task = task
      admin_task.save
    end
  end
end