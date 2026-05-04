# frozen_string_literal: true

class CreateInviteTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :invite_tokens do |t|
      t.references :company, null: false, foreign_key: true
      t.references :creator, foreign_key: { to_table: :users }
      t.string :token, null: false
      t.integer :status, default: 0 # 0: active, 1: used, 2: expired
      t.datetime :expires_at
      t.integer :used_by_id
      t.datetime :used_at

      t.timestamps
    end

    add_index :invite_tokens, :token, unique: true
    add_index :invite_tokens, [:company_id, :status]
    add_foreign_key :invite_tokens, :users, column: :used_by_id
  end
end
