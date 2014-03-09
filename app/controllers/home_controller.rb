class HomeController < ApplicationController

  def main
    @events_to_admin = AdminTaskPresenter.admin_role(current_cake_plan_user)
  end

  def new_event

  end

  def create_event
    @new_task = AdminTaskPresenter.new(params[:new_task])
    respond_to do |format|
      if request.post? && @new_task.create(current_cake_plan_user)
        format.html { redirect_to action: 'main', notice: 'AdminTask was successfully created.' }
      else
        format.html { redirect_to action: 'main', notice: 'AdminTask creation failed.' }
      end
    end
  end
end
