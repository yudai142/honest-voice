class Admin::QuestionsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!
  before_action :set_question, only: [:show, :edit, :update, :destroy]

  # GET /admin/questions
  def index
    all_questions = Question.order(created_at: :desc)
    page = (params[:page] || 1).to_i
    per_page = (params[:per_page] || 10).to_i
    offset = (page - 1) * per_page

    @questions = all_questions.offset(offset).limit(per_page)
    total_count = all_questions.count

    respond_to do |format|
      format.html
      format.json do
        render json: {
          questions: serialize_questions(@questions),
          pagination: {
            total_count: total_count,
            page: page,
            per_page: per_page
          }
        }
      end
    end
  end

  # GET /admin/questions/:id
  def show
    respond_to do |format|
      format.html
      format.json do
        render json: {
          question: serialize_question_with_stats(@question)
        }
      end
    end
  end

  # GET /admin/questions/new
  def new
    @question = Question.new
  end

  # POST /admin/questions
  def create
    @question = Question.new(question_params)
    @question.user = current_user
    @question.status ||= 'draft'

    if @question.save
      render json: { question: serialize_question_with_stats(@question) }, status: :created
    else
      render json: { errors: @question.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /admin/questions/:id/edit
  def edit
  end

  # PATCH /admin/questions/:id
  def update
    if @question.update(question_params)
      render json: { question: @question }, status: :ok
    else
      render json: { errors: @question.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /admin/questions/:id
  def destroy
    @question.destroy
    head :no_content
  end

  private

  def set_question
    @question = Question.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Question not found' }, status: :not_found
  end

  def question_params
    params.require(:question).permit(:title, :body, :description, :text, :question_type, :status, choices_attributes: [:id, :label, :text, :_destroy])
  end

  def serialize_questions(questions)
    questions.map { |q| serialize_question_with_stats(q) }
  end

  def serialize_question_with_stats(question)
    {
      id: question.id,
      title: question.title,
      body: question.body,
      question_type: question.question_type,
      status: question.status,
      choices: question.choices.map { |c| { id: c.id, text: c.label } },
      stats: calculate_stats(question),
      choice_stats: calculate_choice_stats(question),
      created_at: question.created_at,
      updated_at: question.updated_at
    }
  end

  def calculate_stats(question)
    answer_count = question.answers.count
    {
      answer_count: answer_count,
      answer_rate: answer_count > 0 ? (answer_count.to_f / 100 * 100).round(2) : 0
    }
  end

  def calculate_choice_stats(question)
    total_answers = question.answers.count
    return [] if total_answers.zero?

    question.choices.map do |choice|
      choice_answer_count = choice.answers.count
      {
        id: choice.id,
        text: choice.text,
        count: choice_answer_count,
        percentage: (choice_answer_count.to_f / total_answers * 100).round(2)
      }
    end
  end

  def authorize_admin!
    redirect_to root_path, status: :forbidden unless current_user.admin?
  end
end
