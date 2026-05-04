class CreateAnswerTokens < ActiveRecord::Migration[7.2]
  def change
    create_table :answer_tokens do |t|
      t.references :question, null: false, foreign_key: true
      t.string :token, null: false
      t.datetime :expires_at

      t.timestamps
    end

    add_index :answer_tokens, :token, unique: true
  end
end
