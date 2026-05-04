module Admin
  class AdminRepliesController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!
    before_action :set_question
    before_action :set_answer
    before_action :set_admin_reply, only: [:destroy]

    # GET /admin/questions/:question_id/answers/:answer_id/admin_replies
    def index
      @admin_replies = @answer.admin_replies.includes(:user).order(created_at: :desc)
      render json: { admin_replies: serialize_replies(@admin_replies) }
    end

    # POST /admin/questions/:question_id/answers/:answer_id/admin_replies
    def create
      @admin_reply = @answer.admin_replies.build(admin_reply_params)
      @admin_reply.user = current_user

      if @admin_reply.save
        render json: { admin_reply: serialize_reply(@admin_reply) }, status: :created
      else
        render json: { errors: @admin_reply.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # DELETE /admin/questions/:question_id/answers/:answer_id/admin_replies/:id
    def destroy
      @admin_reply.destroy
      head :no_content
    end

    private

    def set_question
      @question = Question.find(params[:question_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Question not found' }, status: :not_found
    end

    def set_answer
      @answer = @question.answers.find(params[:answer_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Answer not found' }, status: :not_found
    end

    def set_admin_reply
      @admin_reply = @answer.admin_replies.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'AdminReply not found' }, status: :not_found
    end

    def admin_reply_params
      params.require(:admin_reply).permit(:reply_text, :status)
    end

    def authorize_admin!
      render json: { error: 'Forbidden' }, status: :forbidden unless current_user.admin?
    end

    def serialize_replies(replies)
      replies.map { |r| serialize_reply(r) }
    end

    def serialize_reply(reply)
      {
        id: reply.id,
        reply_text: reply.reply_text,
        status: reply.status,
        user_id: reply.user_id,
        answer_id: reply.answer_id,
        created_at: reply.created_at,
        updated_at: reply.updated_at
      }
    end
  end
end
