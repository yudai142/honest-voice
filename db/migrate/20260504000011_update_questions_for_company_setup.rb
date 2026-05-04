# frozen_string_literal: true

class UpdateQuestionsForCompanySetup < ActiveRecord::Migration[8.1]
  def change
    # user_id を削除
    remove_column :questions, :user_id, :integer if column_exists?(:questions, :user_id)

    # company_id を追加
    add_reference :questions, :company, foreign_key: true unless column_exists?(:questions, :company_id)

    # Department への参照を追加
    add_reference :questions, :department, foreign_key: true unless column_exists?(:questions, :department_id)

    # ステータス追跡カラムを追加
    add_column :questions, :status, :integer, default: 0 unless column_exists?(:questions, :status)
    add_column :questions, :response_count, :integer, default: 0 unless column_exists?(:questions, :response_count)
  end
end
