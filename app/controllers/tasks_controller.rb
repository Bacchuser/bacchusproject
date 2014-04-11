class TasksController < ApplicationController

  # GET /tasks/1/admin_event
  # GET /tasks/1/admin_event.json
  def admin_event
    # TODO change to query the tree : task_id and level = 1.
    role = UserAdmin.where("task_id = ? AND cake_plan_user_id = ?",
      params[:id], current_cake_plan_user.id).limit(1).first!
    @event = EventPresenter.from_role(role)

    # All the task
    @tasks = Task.where("tree_level > 1 AND event_id = :event_id",
      { event_id: @event.id } ).sort_by { |t| t.new? ? 0 : 1 }

    task = nil
    # The task who is displayed.
    if params[:task_id].nil?
      task = default_task!
    else
      task = Task.where("id = :id AND tree_level > 1",
        { id: params[:task_id] } ).limit(1).first
    end

    return if @tasks.count == 0
    return respond_to do |format|
        format.html {redirect_to admin_event_task_url(@event.task), alert: "subtask not exists !" }
    end if task.nil?

    # We edit the subclass.
    if task.new?
      @task = task
    else
      @task = task.subclass
    end
  end

  #
  # Create an empty task, and then redirect to the main page.
  # TODO check permission.
  #
  def new_task
    params.require(:id)
    task_neutral = Task.new_for_event(parent_event)
    respond_to do |format|
      if task_neutral.save!
        format.html { redirect_to admin_event_task_url(parent_event),
          notice: 'New task created ' + task_neutral.label  }
        format.json { render json: parent_event, status: :created }
      else
        format.html { render action: :admin_event }
        format.json { render json: parent_event.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_subtask
    params.require(:task_id)
    params.require(:save_status)
    task = Task.find(params[:task_id])

    case params[:save_status].downcase
    when "cancel"
      return delete_subtask(task)
    when "create"
      return create_subtask(task)
    when "save"
      return save_subtask(task)
    else
      raise "Illegal save status"
    end
  end

  private
  def delete_subtask(task)
    Rails.logger.info "\n\nDELETE"
    Rails.logger.info task.inspect
    Rails.logger.info UserAdmin.where("task_id = ?", task.id).inspect
    Rails.logger.info "/DELETE\n\n"

    task.destroy
    respond_to do |format|
        format.html { redirect_to admin_event_task_url(parent_event),
          notice: 'Task deleted' }
    end
  end

  def create_subtask(task)
    subclass = nil
    message = ""
    subclass_name = params[:custom][:type].downcase
    if not Task::SUBCLASS_CLASSES.has_key?(subclass_name)
      raise "Type not exists : " + subclass_name + Task::SUBCLASS_CLASSES.inspect
    end

    subclass = Task::SUBCLASS_CLASSES[subclass_name].new do |new_subclass|
      new_subclass.task = task
    end

    saved = Task.transaction do
      subclass.save!
      task.update(params.
        require(:task).
        permit(:label).
        deep_merge( { subclass_id: subclass.id, subclass_name: subclass_name } ))
      task.save!
    end

    respond_to do |format|
      if saved
        format.html { redirect_to admin_event_task_url(parent_event, task_id: task.id),
          notice: "Task created (" << task.subclass_name << ")" }
      end
    end
  end

  def save_subtask(task)
    save_succeed = Task.transaction do
      task.update(params.require(:task).permit(:label))
      # we allow all the attributes to mass asignements.
      subtask_params = task.subclass.class.attribute_names
      task.subclass.update(params.require(:subtask).permit(subtask_params))
    end

    respond_to do |format|
      if save_succeed
        format.html { redirect_to admin_event_task_url(parent_event, task_id: task.id),
          notice: "Task saved (" << task.subclass_name << ")" }
      else
        format.html { redirect_to admin_event_task_url(parent_event, task_id: task.id),
          notice: "Task not saved (" << task.subclass_name << ")" }
      end
    end
  end

  def parent_event
    @parent_event ||= Task.where("id = ?", params[:id]).limit(1).first!
  end

  def default_task!
    @tasks.first
  end
end
