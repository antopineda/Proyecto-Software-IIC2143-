class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

    protected

    # Permite que devise almacene parámetros adicionales como "name, admin, entre otros"
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, 
                                      keys: [:name, :admin, :professor, :age, :college, :knowledges, 
                                             :profile_picture])
      devise_parameter_sanitizer.permit(:account_update, 
                                        keys: [:name, :admin, :professor, :age, :college, :knowledges, 
                                               :profile_picture])
  end
end