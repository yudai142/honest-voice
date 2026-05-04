class QuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :check_member_role
  before_action :set_question

  def show
    @answer = Answer.new
    @already_answered = current_user.answers.exists?(question: @question)
  end

  private

  def set_question
    @question = Question.published.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to member_dashboard_path, alert: '質問が見つかりませんでした。'
  end

  def check_member_role
    redirect_to admin_dashboard_path if current_user.admin?
  end
end
