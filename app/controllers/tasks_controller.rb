class TasksController < ApplicationController

  # GET /tasks/1/admin_event
  # GET /tasks/1/admin_event.json
  def admin_event
    # TODO change to query the tree : task_id and level = 1.
    role = UserAdmin.where("task_id = ? AND cake_plan_user_id = ?",
      params[:id], current_cake_plan_user.id).limit(1).first
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

    if @tasks.count == 0
      return
    end

    if task.nil?
      return respond_to do |format|
        format.html {redirect_to admin_event_task_url(@event.task), alert: "subtask not exists !" }
      end
    end

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
    task.destroy
    respond_to do |format|
        format.html { redirect_to admin_event_task_url(parent_event),
          notice: 'Task deleted' }
    end
  end

  def create_subtask(task)
    task.save!
    subclass = nil
    message = "" # TODO use i18n
    case params[:custom][:type].downcase
    when "simple_task"
      subclass = SimpleTask.new do |simple_task|
        simple_task.task = task
      end
      message = "Simple Task"
    else
      raise "Type not exists : " + params[:custom][:type].downcase
    end

    subclass.save!
    respond_to do |format|
        format.html { redirect_to admin_event_task_url(parent_event, task_id: task.id),
          notice: message + " created" }
    end
  end

  def save_subtask(task)
    raise "Not subclass of Task" if task.new?
    Task.transaction do
      task.save!
      task.subclass.save!
    end
    respond_to do |format|
        format.html { redirect_to admin_event_task_url(parent_event, task_id: task.id ),
          notice: task.subclass.class.name + " saved" }
    end
  end

  def parent_event
    @parent_event ||= Task.where("id = ?", params[:id]).limit(1).first!
  end

  def default_task!
    @tasks.first
  end
end
