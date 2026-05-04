# frozen_string_literal: true

class CreateQuestionTemplates < ActiveRecord::Migration[8.1]
  def change
    create_table :question_templates do |t|
      t.references :company, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.integer :template_type, default: 0 # 0: monthly, 1: quarterly, etc.
      t.text :questions_data # JSON format

      t.timestamps
    end

    add_index :question_templates, [:company_id, :name], unique: true
  end
end
