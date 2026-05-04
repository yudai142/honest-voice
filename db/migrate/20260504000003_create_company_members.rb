# frozen_string_literal: true

class CreateCompanyMembers < ActiveRecord::Migration[8.1]
  def change
    create_table :company_members do |t|
      t.references :company, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :role, default: 2 # 0: owner, 1: manager, 2: member, 3: viewer

      t.timestamps
    end

    add_index :company_members, [:company_id, :user_id], unique: true
  end
end
