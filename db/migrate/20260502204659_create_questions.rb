class CreateQuestions < ActiveRecord::Migration[7.2]
  def change
    create_table :questions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :body
      t.string :question_type
      t.string :status
      t.datetime :deadline

      t.timestamps
    end
  end
end
