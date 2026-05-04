module Admin
  class DashboardController < ApplicationController
    before_action :authenticate_user!
    before_action :check_admin_role

    def index
      # すべての質問を取得（admin は全権限）
      @questions = Question.order(created_at: :desc)
      @total_questions = Question.count
      @total_answers = Answer.count

      respond_to do |format|
        format.html
        format.json do
          render json: {
            dashboard: {
              questions: serialize_questions,
              stats: {
                total_questions: @total_questions,
                total_answers: @total_answers
              }
            }
          }
        end
      end
    end

    private

    def check_admin_role
      redirect_to member_dashboard_path unless current_user.admin?
    end

    def serialize_questions
      @questions.limit(10).map do |question|
        {
          id: question.id,
          title: question.title,
          body: question.body,
          answer_count: question.answers.count,
          created_at: question.created_at
        }
      end
    end
  end
end
