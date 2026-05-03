class AnswersController < ApplicationController
  before_action :set_question, only: [:create, :index]

  # POST /questions/:question_id/answers
  def create
    @answer = @question.answers.build(answer_params)

    # Check for duplicate answers
    session_id = answer_params[:session_id]
    if session_id.present?
      session_hash = Digest::SHA256.hexdigest(session_id)
      if @question.answers.exists?(session_id_hash: session_hash)
        return render json: { errors: ['This session has already answered this question'] }, status: :unprocessable_entity
      end
    end

    if @answer.save
      render json: { answer: @answer }, status: :created
    else
      render json: { errors: @answer.errors.full_messages }, status: :unprocessable_entity
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
    render json: { error: 'Question not found' }, status: :not_found
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
