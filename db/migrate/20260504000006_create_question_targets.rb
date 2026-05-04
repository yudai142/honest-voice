# frozen_string_literal: true

class CreateQuestionTargets < ActiveRecord::Migration[8.1]
  def change
    create_table :question_targets do |t|
      t.references :question, null: false, foreign_key: true
      t.string :targetable_type, null: false
      t.integer :targetable_id, null: false
      t.integer :target_type, default: 0 # 0: department, 1: member, 2: role

      t.timestamps
    end

    add_index :question_targets, [:question_id, :targetable_type, :targetable_id], unique: true, name: 'index_question_targets_on_question_and_targetable'
  end
end
