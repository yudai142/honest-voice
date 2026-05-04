module Member
  class QuestionsController < ApplicationController
    before_action :authenticate_user!
    before_action :check_member_role
    before_action :set_company
    before_action :set_question, only: [:show]

    # GET /member/questions
    def index
      tab = params[:tab].presence || 'unanswered'
      questions = fetch_questions_by_tab(tab)

      respond_to do |format|
        format.html { @questions = questions; @tab = tab }
        format.json do
          render json: {
            questions: questions.map { |q| serialize_question(q) },
            tab: tab
          }
        end
      end
    end

    # GET /member/questions/:id
    def show
      @answer = Answer.new
      @already_answered = @question.answers.exists?(user_id: current_user.id)
    end

    private

    def set_company
      @company = current_user.companies.first || current_user.owned_companies.first
    end

    def set_question
      @question = Question.published.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to member_dashboard_path, alert: '質問が見つかりませんでした。'
    end

    def fetch_questions_by_tab(tab)
      base = @company ? Question.where(company: @company) : Question.none

      case tab
      when 'unanswered'
        answered_ids = current_user.answers.select(:question_id)
        base.published.where.not(id: answered_ids)
      when 'answered'
        answered_ids = current_user.answers.select(:question_id)
        base.published.where(id: answered_ids)
      when 'closed'
        base.closed
      else
        base.published
      end.order(created_at: :desc)
    end

    def serialize_question(question)
      {
        id: question.id,
        title: question.title,
        body: question.body,
        question_type: question.question_type,
        status: question.status,
        created_at: question.created_at
      }
    end

    def check_member_role
      redirect_to admin_dashboard_path if current_user.admin?
    end
  end
end
