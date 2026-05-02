class CreateChoices < ActiveRecord::Migration[7.2]
  def change
    create_table :choices do |t|
      t.references :question, null: false, foreign_key: true
      t.string :label, null: false

      t.timestamps
    end

    add_index :choices, [:question_id, :label], unique: true
  end
end
