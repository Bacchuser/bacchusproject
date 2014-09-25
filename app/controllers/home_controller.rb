class HomeController < ApplicationController

  def main
    @events_to_admin = EventPresenter.admin_role(current_cake_plan_user) unless current_cake_plan_user.nil?
  end

end
