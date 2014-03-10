class HomeController < ApplicationController
  add_flash_types :errors

  def main
    @events_to_admin = AdminTaskPresenter.admin_role(current_cake_plan_user) unless current_cake_plan_user.nil?
  end

  def new_event

  end

  def create_event
    params.require(:new_task)

    @new_task = AdminTaskPresenter.new(params[:new_task])
    respond_to do |format|
      if request.post? && @new_task.create(current_cake_plan_user)
        format.html { redirect_to action: 'main', notice: 'AdminTask was successfully created.' }
      else
        flash.now[:errors] = @new_task.errors.full_messages
        format.html { render action: 'new_event', notice: 'Error'}
      end
    end
  end
end
