class TasksController < ApplicationController

  # GET /tasks/1/admin_event
  # GET /tasks/1/admin_event.json
  def admin_event
    Rails.logger.info ">>>>"
    Rails.logger.info params
    Rails.logger.info ">>>>"
    # TODO change to query the tree : task_id and level = 1.
    role = UserAdmin.where("task_id = ? AND cake_plan_user_id = ?",
      params[:id], current_cake_plan_user.id).limit(1).first
    @event = EventPresenter.from_role(role)

    # All the task details, we don't know the subclass type.
    @tasks = Task.where("tree_level > 1 AND event_id = :event_id",
      { event_id: @event.id } )

    # The task who is displayed.
    if params[:task_id].nil?
      default_task!
    else
      @task = Task.where("id = :id AND tree_level > 1", { id: params[:task_id] } ).limit(1).first
      if @task.nil?
        respond_to do |format|
          format.html {redirect_to admin_event_task_url(@event.task), alert: "subtask not exists !" }
        end
      end
    end
  end


  #
  # Create an empty task, and then redirect to the main page.
  # TODO check permission.
  #
  def new_task
    node = Task.where("id = ?", params[:id]).limit(1).first
    Rails.logger.info "..........."
    Rails.logger.info node.inspect
    Rails.logger.info "..........."
    task_neutral = Task.new_for_event(node)
    respond_to do |format|
      if task_neutral.save!
        format.html { redirect_to admin_event_task_url(node),
          notice: 'New task created ' + task_neutral.label  }
        format.json { render json: node, status: :created }
      else
        format.html { render action: :admin_event }
        format.json { render json: node.errors, status: :unprocessable_entity }
      end
    end
  end


  private

  def default_task!
    @task = @tasks.first
  end
end
