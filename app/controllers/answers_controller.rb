class AnswersController < ApplicationController
  before_action :authenticate_user!, only: [:create]
  before_action :set_question, only: [:create, :index]

  # POST /questions/:question_id/answers
  def create
    @answer = @question.answers.build(answer_params)

    # 重複チェック
    session_id_value = answer_params[:session_id].presence || session.id.to_s
    session_hash = Digest::SHA256.hexdigest(session_id_value)

    if @question.answers.exists?(session_id_hash: session_hash)
      respond_to do |format|
        format.html { redirect_to question_path(@question), alert: 'すでに回答済みです。' }
        format.json { render json: { errors: ['This session has already answered this question'] }, status: :unprocessable_entity }
      end
      return
    end

    @answer.user = current_user if user_signed_in?

    if @answer.save
      respond_to do |format|
        format.html { redirect_to member_dashboard_path, notice: '回答を送信しました。' }
        format.json { render json: { answer: @answer }, status: :created }
      end
    else
      respond_to do |format|
        format.html do
          @already_answered = false
          render 'questions/show', status: :unprocessable_entity
        end
        format.json { render json: { errors: @answer.errors.full_messages }, status: :unprocessable_entity }
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
    respond_to do |format|
      format.html { redirect_to member_dashboard_path, alert: '質問が見つかりませんでした。' }
      format.json { render json: { error: 'Question not found' }, status: :not_found }
    end
  end

  def answer_params
    params.require(:answer).permit(:body, :session_id, :choice_id)
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
