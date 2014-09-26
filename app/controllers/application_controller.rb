class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_filter :set_events!
  add_flash_types :warning, :danger, :info, :success

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit! }
  end

  private

  def set_events!
    @events = EventPresenter.admin_role(current_cake_plan_user) unless current_cake_plan_user.nil?
  end
end
