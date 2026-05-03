module Admin
  class FormsController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!, only: [:template, :validate_question]

    # GET /admin/form-template.json
    def template
      question_type = params[:question_type]
      
      template = build_form_template(question_type)
      render json: { template: template }, status: :ok
    end

    # POST /admin/validate-question
    def validate_question
      @question = Question.new(question_params)
      @question.user = current_user
      @question.status ||= 'draft'
      
      if @question.valid?
        render json: { valid: true }, status: :ok
      else
        errors = @question.errors.full_messages.map { |msg| { message: msg, field: extract_field(msg) } }
        render json: { valid: false, errors: errors }, status: :ok
      end
    end

    private

    def build_form_template(question_type)
      case question_type
      when 'text'
        {
          question_type: 'text',
          fields: [
            { name: 'title', type: 'text', label: '質問タイトル', required: true },
            { name: 'body', type: 'textarea', label: '質問本文', required: true },
            { name: 'status', type: 'select', label: 'ステータス', 
              options: [{ label: 'Draft', value: 'draft' }, { label: 'Published', value: 'published' }] }
          ]
        }
      when 'choice'
        {
          question_type: 'choice',
          fields: [
            { name: 'title', type: 'text', label: '質問タイトル', required: true },
            { name: 'body', type: 'textarea', label: '質問本文', required: true },
            { name: 'choices_attributes', type: 'dynamic_array', label: '選択肢',
              item_template: { name: 'label', type: 'text', label: '選択肢テキスト' } },
            { name: 'status', type: 'select', label: 'ステータス',
              options: [{ label: 'Draft', value: 'draft' }, { label: 'Published', value: 'published' }] }
          ]
        }
      when 'rating'
        {
          question_type: 'rating',
          fields: [
            { name: 'title', type: 'text', label: '質問タイトル', required: true },
            { name: 'body', type: 'textarea', label: '質問本文', required: true },
            { name: 'choices_attributes', type: 'dynamic_array', label: 'レーティング段階',
              item_template: { name: 'label', type: 'text', label: 'レベルラベル' } },
            { name: 'status', type: 'select', label: 'ステータス',
              options: [{ label: 'Draft', value: 'draft' }, { label: 'Published', value: 'published' }] }
          ]
        }
      else
        { error: 'Invalid question_type' }
      end
    end

    def question_params
      params.require(:question).permit(:title, :body, :question_type, :status, choices_attributes: [:id, :label, :_destroy])
    end

    def extract_field(error_message)
      case error_message
      when /title/i
        'title'
      when /body/i
        'body'
      when /question_type/i
        'question_type'
      when /choice/i
        'choices_attributes'
      else
        'unknown'
      end
    end

    def authorize_admin!
      redirect_to root_path, status: :forbidden unless current_user.admin?
    end
  end
end
