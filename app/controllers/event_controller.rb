class EventController < ApplicationController

  def create
    @new_task = EventPresenter.new(params.require(:task).permit(:label, :description, :city, :street,
      :country, :longitude, :latitude,
      :start_at, :end_at))

    respond_to do |format|
      if @new_task.create(current_cake_plan_user)
        #TODO Redirect to admin page directly
        flash.now[:success] = 'Event was successfully created.'
        format.html { redirect_to event_subtask_index_url(@new_task.task) }
      else
        flash.now[:danger] = 'Error creating the event. '
        format.html { redirect_to new_event_path() }
      end
    end
  end

end
