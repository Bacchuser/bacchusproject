class TasksController < ApplicationController

  # GET /tasks/1/admin_event
  # GET /tasks/1/admin_event.json
  def admin_event
    params.require(:id)
    # TODO change to query the tree : task_id and level = 1.
    role = UserAdmin.where("admin_task_id = ? AND cake_plan_user_id = ?",
      params[:id], current_cake_plan_user.id).limit(1).first
    @event = AdminTaskPresenter.from_role(role)
    @task = Task.new
  end
end
