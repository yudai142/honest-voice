# frozen_string_literal: true

class AddTemplateAndScopeToRecurringSchedules < ActiveRecord::Migration[8.1]
  def change
    add_reference :recurring_schedules, :question_template, foreign_key: { to_table: :question_templates }, null: true
    add_column :recurring_schedules, :target_scope, :string, default: 'all', null: false
  end
end
