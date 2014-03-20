module TasksHelper

  def subclass_partial(task)
    if not task.new?
      render partial: task.subclass.class.name.tr(':', '_').downcase
    else
      render partial: 'new_task'
    end
  end
end
