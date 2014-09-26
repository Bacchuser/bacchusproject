class SubtaskController < ApplicationController

  before_action :constants!

  def index
    task = default_task!

    return if @tasks.count == 0
    return respond_to do |format|
        format.html {redirect_to event_subtask_index_url(event_id: task.id), alert: "subtask not exists !" }
    end if task.nil?

    # We edit the subclass.
    if task.new?
      @task = task
    else
      @task = task.subclass
    end
  end

  def create
    task_neutral = Task.new_for_event( @event.event )
    respond_to do |format|
      if task_neutral.save!
        format.html { redirect_to event_subtask_index_url( event_id: params.require(:event_id) ),
          success: 'New task created ' + task_neutral.label  }
        format.json { render json: parent_event, status: :created }
      else
        flash.now[:error] = 'Error creating the task'
        format.html { render action: :index }
        format.json { render json: parent_event.errors, status: :unprocessable_entity }
      end
    end
  end

  # Define a subtask for the current subtask
  def define_leaf
    task = Task.find(params.require(:id))
    if not task.subclass_name.nil? or not task.subclass_id.nil?
      raise "The task is already define by a subtask #{task.subclass_name} (##{task.subclass_id})"
    end
    create_subtask_for(task, task.id)
  end

  # Add a leaf to the current task
  # The leaf will be directly define a subclass_name.
  def add_leaf
    parent_task = Task.find(params.require(:id))
    child_task = parent_task.new_child()
    return create_subtask_for(child_task, parent_task.id)
  end

  # Update the task and it's subtask
  def update_leaf
    task_params = params.require(:task)
    task = Task.find(params.require(:id))
    return save_subtask(task, task_params)
  end

  # Remove a task and it's subtask.
  def remove_leaf
    task = Task.find(params.require(:id))
    return delete_subtask(task)
  end

  # Show a task. The subtask will be given, not the node.
  def show
    @task = Task.where("id = :id AND tree_level == 2",
        { id: params.require(:id) } ).limit(1).first.subclass
    if @task.nil?
      @task = parent_event
    end
    render :index
  end


  private

  def default_task!
    @tasks.first
  end

  def delete_subtask(task)
    Rails.logger.info "\n\nDELETE"
    Rails.logger.info task.inspect
    Rails.logger.info UserAdmin.where("task_id = ?", task.id).inspect
    Rails.logger.info "/DELETE\n\n"

    task.destroy
    respond_to do |format|
        format.html { redirect_to event_subtask_url(parent_event),
          notice: 'Task deleted' }
    end
  end

  # Add a specialisation to the task could be a class from  Task::SUBCLASS_CLASSES
  def create_subtask_for(task, link_to_id)
    subclass = nil
    message = ""
    subclass_name = params.require(:custom).require(:type).downcase
    if not Task::SUBCLASS_CLASSES.has_key?(subclass_name)
      raise "Type not exists : " + subclass_name + Task::SUBCLASS_CLASSES.inspect
    end

    subclass = Task::SUBCLASS_CLASSES[subclass_name].new
    saved = Task.transaction do
      subclass.task_id = link_to_id
      subclass.save!

      task.subclass_name = subclass_name
      task.subclass_id = subclass.id
      task.save!
    end

    respond_to do |format|
      if saved
        flash.now[:success] =  "Task created (" << subclass_name << ")"
        format.html { redirect_to event_subtask_url(event_id: params.require(:event_id) , id: link_to_id)}
      end
    end
  end

  def save_subtask(task, task_params)
    subtask_params = params.require(task.subclass_name)
    save_succeed = Task.transaction do
      task.update(task_params.permit(:label))
      if not subtask_params.empty?
        # we allow all the attributes to mass assignements.
        subtask_params_permit = subtask_params.permit(task.subclass.accessible)
        task.subclass.update_attributes subtask_params_permit
      end
    end

    respond_to do |format|
      if save_succeed
        format.html { redirect_to event_subtask_url(params.require(:event_id) , task.id),
          success: "Task saved (" << task.subclass_name << ")" }
      else
        format.html { redirect_to event_subtask_url(params.require(:event_id) , task.id),
          danger: "Task not saved (" << task.subclass_name << ")" }
      end
    end
  end

  def parent_event
    @parent_event ||= Task.where("id = ?", params.require(:event_id)).limit(1).first!
  end

  def constants!
    # TODO change to query the tree : task_id and level = 1.
    role = UserAdmin.where("task_id = ? AND cake_plan_user_id = ?",
      params.require(:event_id), current_cake_plan_user.id).limit(1).first!
    @event = EventPresenter.from_role(role)

    # All the task
    @tasks = Task.where("tree_level == 2 AND event_id = :event_id",
      { event_id: @event.id } ).sort_by { |t| t.new? ? 0 : 1 }
  end
end
