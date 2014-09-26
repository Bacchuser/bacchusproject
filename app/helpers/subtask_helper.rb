module SubtaskHelper

  def subclass_partial(prefix, task)
    if task.subclass?
      render partial: prefix << "_" << task.class.name.demodulize.downcase
    else
      render partial: prefix << "_" << 'new_task'
    end
  end

  def status(task)
    return "new" if task.new?
    return "active" if not @task.nil? and ((@task.new? and task.id == @task.id) or (not @task.new? and task.id == @task.task_id))
  end

  def navigation_class(task)
    classes = ["list-group-item"]
    classes << status(task)
    return classes
  end
end
