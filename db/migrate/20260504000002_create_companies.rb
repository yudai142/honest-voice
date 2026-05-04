# frozen_string_literal: true

class CreateCompanies < ActiveRecord::Migration[8.1]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.text :description
      t.references :owner, foreign_key: { to_table: :users }
      t.integer :visibility, default: 0
      t.integer :member_count, default: 0
      t.integer :question_count, default: 0

      t.timestamps
    end

    add_index :companies, :name
    add_index :companies, :owner_id
  end
end
