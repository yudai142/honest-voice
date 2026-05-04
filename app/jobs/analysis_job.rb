# frozen_string_literal: true

class AnalysisJob < ApplicationJob
  queue_as :default

  def perform(question_id)
    question = Question.find(question_id)
    AnalysisService.new(question: question).call
  end
end