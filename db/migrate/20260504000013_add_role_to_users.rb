# frozen_string_literal: true

class AddRoleToUsers < ActiveRecord::Migration[8.1]
  def up
    return if column_exists?(:users, :role)

    add_column :users, :role, :string, default: 'member', null: false
  end

  def down
    return unless column_exists?(:users, :role)

    remove_column :users, :role
  end
end
