# frozen_string_literal: true

class ReminderJob < ApplicationJob
  queue_as :mailers

  def perform(question_id, days_before_deadline)
    question = Question.find(question_id)
    return if question.deadline.blank?

    answered_user_ids = question.answers.where.not(user_id: nil).distinct.pluck(:user_id)

    question.company.users.where(notification_enabled: true).where.not(id: answered_user_ids).find_each do |user|
      ReminderMailer.question_reminder(user, question, days_before_deadline).deliver_later
    end
  end
end