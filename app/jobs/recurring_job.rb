# frozen_string_literal: true

class RecurringJob < ApplicationJob
  queue_as :default

  def perform
    enqueue_deadline_reminders(3)
    enqueue_deadline_reminders(1)

    RecurringSchedule.active_schedules.due_today.find_each do |schedule|
      AnalysisJob.perform_later(schedule.question_id) if schedule.question_id.present?
      schedule.mark_as_run
    end
  end

  private

  def enqueue_deadline_reminders(days_before_deadline)
    target_date = days_before_deadline.days.from_now.to_date
    range = target_date.beginning_of_day..target_date.end_of_day

    Question.published.where(deadline: range).find_each do |question|
      ReminderJob.perform_later(question.id, days_before_deadline)
    end
  end
end