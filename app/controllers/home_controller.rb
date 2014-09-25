class HomeController < ApplicationController

  def main
    @events_to_admin = EventPresenter.admin_role(current_cake_plan_user) unless current_cake_plan_user.nil?
  end

  def new_event

  end

  def create_event
    params.require(:new_task)

    @new_task = EventPresenter.new(params[:new_task])

    respond_to do |format|
      if @new_task.create(current_cake_plan_user)
        #TODO Redirect to admin page directly
        flash.now[:success] = 'Event was successfully created.'
        format.html { redirect_to admin_event_task_url(@new_task.task) }
      else
        flash.now[:danger] = 'Error creating the event. '
        format.html { render action: 'new_event' }
      end
    end
  end
end
