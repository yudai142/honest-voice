class AnswersController < ApplicationController
  before_action :authenticate_user!, only: [:create], if: :html_form_request?
  before_action :set_question, only: [:create, :index]

  # POST /questions/:question_id/answers
  def create
    @answer = @question.answers.build(answer_params)
    apply_rating_fallback_choice!

    # 重複チェック
    session_id_value = answer_params[:session_id].presence || session.id.to_s
    session_hash = Digest::SHA256.hexdigest(session_id_value)

    if @question.answers.exists?(session_id_hash: session_hash)
      if html_form_request?
        redirect_to question_path(@question), alert: 'すでに回答済みです。'
      else
        render json: { errors: ['This session has already answered this question'] }, status: :unprocessable_entity
      end
      return
    end

    @answer.user = current_user if html_form_request? && user_signed_in?

    if @answer.save
      if html_form_request?
        redirect_to member_dashboard_path, notice: '回答を送信しました。'
      else
        render json: { answer: @answer }, status: :created
      end
    else
      if html_form_request?
        @already_answered = false
        render 'questions/show', status: :unprocessable_entity
      else
        render json: { errors: @answer.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  # GET /questions/:question_id/answers
  def index
    page = (params[:page] || 1).to_i
    per_page = (params[:per_page] || 10).to_i
    offset = (page - 1) * per_page

    all_answers = @question.answers.includes(:choice).order(created_at: :desc)
    @answers = all_answers.offset(offset).limit(per_page)
    total_count = all_answers.count

    render json: {
      answers: @answers.map { |a| serialize_answer(a) },
      pagination: {
        total_count: total_count,
        page: page,
        per_page: per_page
      }
    }, status: :ok
  end

  private

  def set_question
    @question = Question.find(params[:question_id])
  rescue ActiveRecord::RecordNotFound
    if html_form_request?
      redirect_to member_dashboard_path, alert: '質問が見つかりませんでした。'
    else
      render json: { error: 'Question not found' }, status: :not_found
    end
  end

  def answer_params
    params.require(:answer).permit(:body, :session_id, :choice_id)
  end

  def html_form_request?
    params[:format] == 'html'
  end

  def apply_rating_fallback_choice!
    return unless @question.rating?
    return if @answer.choice_id.present?

    rating_value = params.dig(:answer, :rating_value).to_s
    return unless rating_value.match?(/\A[1-5]\z/)

    choice = @question.choices.find_by(label: rating_value)
    choice ||= @question.choices.order(:id)[rating_value.to_i - 1]
    choice ||= @question.choices.find_or_create_by!(label: rating_value)
    @answer.choice = choice
  end

  def serialize_answer(answer)
    {
      id: answer.id,
      body: answer.body,
      choice_id: answer.choice_id,
      created_at: answer.created_at,
      updated_at: answer.updated_at
    }
  end
end
