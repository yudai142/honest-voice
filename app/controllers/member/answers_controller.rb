module Member
  class AnswersController < ApplicationController
    before_action :authenticate_user!
    before_action :check_member_role

    def index
      @answers = current_user.answers.includes(:question).order(created_at: :desc)
    end

    private

    def check_member_role
      redirect_to admin_dashboard_path if current_user.admin?
    end
  end
end
