module Admin
  class DashboardController < ApplicationController
    before_action :authenticate_user!
    before_action :check_admin_role

    def index
      @questions = Question.where(user_id: current_user.id)
      @total_questions = Question.where(user_id: current_user.id).count
      @total_answers = Answer.joins(:question).where(questions: { user_id: current_user.id }).count
    end

    private

    def check_admin_role
      redirect_to member_dashboard_path unless current_user.admin?
    end
  end
end
