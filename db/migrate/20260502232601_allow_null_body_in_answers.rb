class AllowNullBodyInAnswers < ActiveRecord::Migration[8.1]
  def change
    change_column_null :answers, :body, true
  end
end
