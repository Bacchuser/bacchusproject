module TasksHelper

  def subclass_partial(task)
    if task.subclass?
      render partial: task.class.name.demodulize.downcase
    else
      render partial: 'new_task'
    end
  end

  def navigation_class(task)
    classes = ["list-group-item"]
    classes << "new" if task.new?
    classes << "active" if not @task.nil? and ((@task.new? and task.id == @task.id) or (not @task.new? and task.id == @task.task_id))
    return classes
  end
end
