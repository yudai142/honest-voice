class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!, unless: :devise_controller?
  before_action :redirect_based_on_role, if: :root_path?, unless: :devise_controller?

  protected

  def root_path?
    request.path == '/'
  end

  def redirect_based_on_role
    return unless user_signed_in?

    if current_user.admin?
      redirect_to '/admin/dashboard'
    elsif current_user.member?
      redirect_to '/member/dashboard'
    end
  end
end
