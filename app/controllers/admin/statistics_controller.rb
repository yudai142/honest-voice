module Admin
  class StatisticsController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!
    before_action :set_question

    # GET /admin/questions/:question_id/statistics
    def show
      respond_to do |format|
        format.html { render :show }
        format.json do
          render json: {
            question: serialize_question,
            stats: calculate_stats,
            answers: serialize_answers,
            choice_stats: calculate_choice_stats,
            charts: build_chart_data
          }
        end
      end
    end

    private

    def set_question
      @question = Question.find(params[:question_id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Question not found' }, status: :not_found
    end

    def serialize_question
      {
        id: @question.id,
        title: @question.title,
        body: @question.body,
        question_type: @question.question_type,
        status: @question.status
      }
    end

    def calculate_stats
      total_answers = @question.answers.count
      {
        total_answers: total_answers,
        answer_rate: total_answers > 0 ? (total_answers.to_f / 100).round(2) : 0,
        average_rating: calculate_average_rating
      }
    end

    def serialize_answers
      @question.answers.map do |answer|
        {
          id: answer.id,
          body: answer.body,
          created_at: answer.created_at,
          session_id_hash: answer.session_id_hash
        }
      end
    end

    def calculate_choice_stats
      return [] unless @question.choice? || @question.rating?

      @question.choices.map do |choice|
        count = choice.answers.count
        total = @question.answers.count
        rate = total > 0 ? (count.to_f / total * 100).round(2) : 0
        {
          id: choice.id,
          label: choice.label,
          count: count,
          rate: rate
        }
      end
    end

    def build_chart_data
      case @question.question_type
      when 'choice', 'rating'
        build_choice_chart_data
      else
        {}
      end
    end

    def build_choice_chart_data
      choices = calculate_choice_stats
      return {} if choices.empty?

      {
        bar_data: choices.map do |choice|
          {
            label: choice[:label],
            y: choice[:count]
          }
        end,
        pie_data: choices.map do |choice|
          {
            name: choice[:label],
            y: choice[:rate]
          }
        end,
        colors: generate_chart_colors(choices.length)
      }
    end

    def generate_chart_colors(count)
      # DaisyUI カラーパレット
      palette = ['#3B82F6', '#10B981', '#F59E0B', '#EF4444', '#8B5CF6', '#EC4899', '#14B8A6', '#F97316']
      (0...count).map { |i| palette[i % palette.length] }
    end

    def calculate_average_rating
      return nil unless @question.rating?

      total_score = 0
      total_count = 0

      @question.choices.each do |choice|
        count = choice.answers.count
        # 選択肢ラベルから数字を抽出（例：「1点」→ 1）
        rating = choice.label.to_i
        total_score += rating * count
        total_count += count
      end

      total_count > 0 ? (total_score.to_f / total_count).round(2) : nil
    end

    def authorize_admin!
      redirect_to root_path, status: :forbidden unless current_user.admin?
    end
  end
end
