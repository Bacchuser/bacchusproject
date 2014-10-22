module SubtaskHelper

  def subtask_partial(prefix, task)
    if task.is_subtask?
      render partial: prefix << "_" << task.class.name.demodulize.downcase
    else
      render partial: prefix << "_" << 'new_task'
    end
  end

  def status(subtask)
    return "active" if not @task.nil? and (subtask.id == @task.id)
  end

  def navigation_class(task)
    classes = ["list-group-item"]
    classes << status(task)
    return classes
  end
end
