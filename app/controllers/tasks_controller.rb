class TasksController < ApplicationController

  # GET /tasks/1/admin_event
  # GET /tasks/1/admin_event.json
  def admin_event
    params.require(:id)
    role = UserAdmin.where("admin_task_id = ? AND cake_plan_user_id = ?",
      params[:id], current_cake_plan_user.id).limit(1).first
    @task = AdminTaskPresenter.from_role(role)
  end
end
