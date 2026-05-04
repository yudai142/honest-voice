class AddUsageFieldsToInviteTokens < ActiveRecord::Migration[8.1]
  def change
    add_column :invite_tokens, :active, :boolean, default: true, null: false
    add_column :invite_tokens, :max_uses, :integer, default: 1, null: false
    add_column :invite_tokens, :use_count, :integer, default: 0, null: false
  end
end