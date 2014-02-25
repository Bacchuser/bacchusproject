class HomeController < ApplicationController

  def main
    if current_user.register?
      @current_user = current_user
    else
      @current_user = CakePlanUser.new
    end

    @public_events = AdminTaskPresenter.all

  end

  def create_event
    @new_task = AdminTaskPresenter.new(params[:new_task])
    @new_task.save
    respond_to do |format|
      if request.post? && @new_task.save
        format.html { redirect_to action: 'main', notice: 'AdminTask was successfully created.' }
      else
        format.html { redirect_to action: 'main', notice: 'AdminTask creation failed.' }
      end
    end
  end
end
