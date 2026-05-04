class AddStatusToQuestionAnalyses < ActiveRecord::Migration[8.1]
  def change
    add_column :question_analyses, :status, :integer, default: 0, null: false
  end
end