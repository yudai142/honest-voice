# frozen_string_literal: true

class RecurringSchedule < ApplicationRecord
  belongs_to :company
  belongs_to :question, optional: true

  validates :company_id, presence: true
  validates :name, presence: true

  enum frequency: { monthly: 0, quarterly: 1, yearly: 2 }
  enum status: { active: 0, paused: 1, completed: 2 }

  scope :active_schedules, -> { where(status: :active) }
  scope :due_today, -> { where('next_scheduled_at <= ?', Time.current) }

  def due?
    next_scheduled_at && next_scheduled_at <= Time.current
  end

  def mark_as_run
    update(last_run_at: Time.current, next_scheduled_at: calculate_next_run_date)
  end

  private

  def calculate_next_run_date
    case frequency
    when 'monthly'
      next_scheduled_at&.next_month || 1.month.from_now
    when 'quarterly'
      next_scheduled_at&.+ 3.months || 3.months.from_now
    when 'yearly'
      next_scheduled_at&.next_year || 1.year.from_now
    end
  end
end
