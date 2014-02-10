class HomeController < ApplicationController

  def main
    if current_user.register?
      @current_user = current_user
    else
      @current_user = CakePlanUser.new()
    end

    @public_events = AdminTask.where("is_public")
  end
end
