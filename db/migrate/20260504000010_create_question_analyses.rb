# frozen_string_literal: true

class CreateQuestionAnalyses < ActiveRecord::Migration[8.1]
  def change
    create_table :question_analyses do |t|
      t.references :question, null: false, foreign_key: true
      t.references :company, null: false, foreign_key: true
      t.integer :total_responses, default: 0
      t.float :average_rating, default: 0.0
      t.text :sentiment_summary
      t.text :keywords
      t.datetime :analyzed_at

      t.timestamps
    end

    add_index :question_analyses, [:question_id, :company_id], unique: true
  end
end
