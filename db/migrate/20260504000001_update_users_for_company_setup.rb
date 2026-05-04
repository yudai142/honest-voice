# frozen_string_literal: true

class UpdateUsersForCompanySetup < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :name, :string
    add_column :users, :notification_enabled, :boolean, default: true

  end
end
