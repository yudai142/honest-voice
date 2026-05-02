require 'spec_helper'
require 'rails'
require 'rspec/rails'

# テストDB設定
ENV['RAILS_ENV'] = 'test'

# Active Record マイグレーション
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::NoDatabaseError
  puts 'Database not set up yet'
end

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end
