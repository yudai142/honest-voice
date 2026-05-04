# frozen_string_literal: true

class UpdateAnswersForCompanySetup < ActiveRecord::Migration[8.1]
  def change
    # company_id を追加
    add_reference :answers, :company, foreign_key: true unless column_exists?(:answers, :company_id)
  end
end
