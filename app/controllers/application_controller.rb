class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern

  protected

  def redirect_based_on_role
    return unless user_signed_in?

    if current_user.admin?
      redirect_to '/admin/dashboard'
    elsif current_user.member?
      redirect_to '/member/dashboard'
    end
  end
end
