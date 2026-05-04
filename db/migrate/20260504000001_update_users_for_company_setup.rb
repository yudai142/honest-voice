# frozen_string_literal: true

class UpdateUsersForCompanySetup < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :name, :string
    add_column :users, :notification_enabled, :boolean, default: true

    # role カラムが存在する場合は削除
    remove_column :users, :role, :string if column_exists?(:users, :role)
  end
end
