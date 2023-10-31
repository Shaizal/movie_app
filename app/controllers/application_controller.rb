class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :users_registrations_controller?

  protected

  def users_registrations_controller?
    controller_name == 'users/registrations' # Adjust the controller name as needed
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])
  end
end
