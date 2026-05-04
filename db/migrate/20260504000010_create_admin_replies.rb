# frozen_string_literal: true

class CreateAdminReplies < ActiveRecord::Migration[8.1]
  def change
    create_table :admin_replies do |t|
      t.references :answer, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :reply_text, null: false
      t.integer :status, default: 0 # 0: draft, 1: published, 2: archived

      t.timestamps
    end

    add_index :admin_replies, [:answer_id, :user_id]
  end
end
