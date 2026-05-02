class CreateAnswers < ActiveRecord::Migration[7.2]
  def change
    create_table :answers do |t|
      t.references :question, null: false, foreign_key: true
      t.references :user, null: true, foreign_key: true
      t.references :choice, null: true, foreign_key: true
      t.text :body, null: false
      t.string :session_id
      t.string :session_id_hash, null: false

      t.timestamps
    end

    add_index :answers, [:question_id, :session_id_hash], unique: true, name: :index_answers_on_question_and_session_hash
    add_index :answers, :session_id_hash
  end
end
