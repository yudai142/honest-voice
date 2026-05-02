class Admin::ChoicesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!
  before_action :set_question
  before_action :set_choice, only: [:update, :destroy]

  # POST /admin/questions/:question_id/choices
  def create
    @choice = @question.choices.build(choice_params)

    if @choice.save
      render json: { choice: @choice }, status: :created
    else
      render json: { errors: @choice.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PATCH /admin/questions/:question_id/choices/:id
  def update
    if @choice.update(choice_params)
      render json: { choice: @choice }, status: :ok
    else
      render json: { errors: @choice.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /admin/questions/:question_id/choices/:id
  def destroy
    @choice.destroy
    head :no_content
  end

  private

  def set_question
    @question = Question.find(params[:question_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Question not found' }, status: :not_found
  end

  def set_choice
    @choice = @question.choices.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Choice not found' }, status: :not_found
  end

  def choice_params
    params.require(:choice).permit(:text)
  end

  def authorize_admin!
    redirect_to root_path, status: :forbidden unless current_user.admin?
  end
end
