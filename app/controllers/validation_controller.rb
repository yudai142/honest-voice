class ValidationController < ApplicationController
  # POST /validate-answer
  def validate_answer
    question = Question.find(params[:question_id])
    @answer = question.answers.build(answer_params)

    if @answer.valid?
      render json: { valid: true }, status: :ok
    else
      errors = @answer.errors.full_messages.map { |msg| { message: msg, field: extract_field(msg) } }
      render json: { valid: false, errors: errors }, status: :ok
    end
  rescue ActiveRecord::RecordNotFound
    render json: { valid: false, errors: [{ message: 'Question not found', field: 'question_id' }] }, status: :ok
  end

  private

  def answer_params
    params.require(:answer).permit(:body, :session_id, :choice_id)
  end

  def extract_field(error_message)
    case error_message
    when /body/i
      'body'
    when /session_id/i
      'session_id'
    when /choice/i
      'choice_id'
    else
      'unknown'
    end
  end
end
