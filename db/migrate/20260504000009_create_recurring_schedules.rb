# frozen_string_literal: true

class CreateRecurringSchedules < ActiveRecord::Migration[8.1]
  def change
    create_table :recurring_schedules do |t|
      t.references :company, null: false, foreign_key: true
      t.references :question, foreign_key: true
      t.string :name, null: false
      t.integer :frequency, default: 0 # 0: monthly, 1: quarterly, 2: yearly
      t.integer :day_of_month
      t.datetime :next_scheduled_at
      t.datetime :last_run_at
      t.integer :status, default: 0 # 0: active, 1: paused, 2: completed

      t.timestamps
    end

    add_index :recurring_schedules, [:company_id, :frequency]
  end
end
