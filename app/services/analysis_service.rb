# frozen_string_literal: true

class AnalysisService
  MINIMUM_RESPONSES = 5
  MODEL_NAME = 'claude-opus-4-5'

  def initialize(question:, client: nil)
    @question = question
    @client = client || default_client
  end

  def call
    analysis = ensure_analysis_record
    analysis.update!(total_responses: @question.answers.count)
    return analysis unless @question.eligible_for_analysis?

    analysis.processing!
    parsed = parse_response(create_message)

    analysis.update!(
      sentiment_summary: parsed[:sentiment_summary],
      average_rating: parsed[:average_rating].to_f,
      total_responses: parsed[:total_responses].to_i,
      analyzed_at: Time.current,
      status: :completed
    )
    analysis.keywords_array = Array(parsed[:keywords]).map(&:to_s)
    analysis.save!
    analysis
  rescue StandardError
    analysis ||= ensure_analysis_record
    analysis.update(status: :failed, total_responses: @question.answers.count)
    analysis
  end

  private

  def ensure_analysis_record
    QuestionAnalysis.find_or_create_by!(question: @question, company: @question.company) do |analysis|
      analysis.status = :pending
      analysis.total_responses = @question.answers.count
    end
  end

  def create_message
    @client.messages.create(
      model: MODEL_NAME,
      max_tokens: 800,
      messages: [
        {
          role: 'user',
          content: build_prompt
        }
      ]
    )
  end

  def build_prompt
    <<~PROMPT
      次のアンケート回答を分析し、JSONのみで返してください。
      keys は sentiment_summary, keywords, average_rating, total_responses です。

      質問タイトル: #{@question.title}
      質問本文: #{@question.body}
      質問タイプ: #{@question.question_type}
      回答数: #{@question.answers.count}

      回答一覧:
      #{formatted_answers}
    PROMPT
  end

  def formatted_answers
    @question.answers.includes(:choice).order(:created_at).map do |answer|
      if answer.body.present?
        "- #{answer.body}"
      elsif answer.choice.present?
        "- #{answer.choice.label}"
      else
        '- 回答なし'
      end
    end.join("\n")
  end

  def parse_response(response)
    content = extract_content(response)
    text = Array(content).find { |item| content_text(item).present? }
    JSON.parse(content_text(text), symbolize_names: true)
  end

  def extract_content(response)
    return response['content'] if response.is_a?(Hash)
    return response[:content] if response.is_a?(Hash)

    response.content
  end

  def content_text(item)
    return if item.blank?
    return item['text'] if item.is_a?(Hash)
    return item[:text] if item.respond_to?(:[]) && item[:text]

    item.respond_to?(:text) ? item.text : nil
  end

  def default_client
    api_key = ENV['ANTHROPIC_API_KEY']
    raise 'ANTHROPIC_API_KEY is not configured' if api_key.blank?

    Anthropic::Client.new(access_token: api_key)
  end
end