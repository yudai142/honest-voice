module Member
  class DashboardController < ApplicationController
    before_action :authenticate_user!
    before_action :check_member_role

    def index
      @questions = Question.where(status: :published)
      @total_questions = Question.where(status: :published).count
      @answered_questions = current_user.answers.distinct.count(:question_id)
    end

    private

    def check_member_role
      redirect_to admin_dashboard_path if current_user.admin?
    end
  end
end
