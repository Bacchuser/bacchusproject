class HomeController < ApplicationController

<<<<<<< HEAD
=======
  def main
    @events_to_admin = EventPresenter.admin_role(current_cake_plan_user) unless current_cake_plan_user.nil?
  end

  def new_event

  end

  def gen_question

  end

  def create_event
    params.require(:new_task)

    @new_task = EventPresenter.new(params[:new_task])
    respond_to do |format|
      if request.post? && @new_task.create(current_cake_plan_user)
        #TODO Redirect to admin page directly
        format.html { redirect_to admin_event_task_url(@new_task.task), notice: 'Event was successfully created.' }
      else
        format.html { render action: 'new_event', notice: 'Error'}
      end
    end
  end
>>>>>>> Design-proto
end
