require 'rails_helper'

RSpec.describe 'Production/Security configuration' do
  it 'spec/support/factory_bot.rb が存在する' do
    expect(File.exist?(Rails.root.join('spec/support/factory_bot.rb'))).to be(true)
  end

  it 'FactoryBot 定義が users/questions/answers に分割されている' do
    expect(File.exist?(Rails.root.join('spec/factories/users.rb'))).to be(true)
    expect(File.exist?(Rails.root.join('spec/factories/questions.rb'))).to be(true)
    expect(File.exist?(Rails.root.join('spec/factories/answers.rb'))).to be(true)
  end

  it '.env.example に SECRET_KEY_BASE が定義されている' do
    env_text = File.read(Rails.root.join('.env.example'))
    expect(env_text).to include('SECRET_KEY_BASE=')
  end

  it 'production database が DATABASE_URL を利用する' do
    database_yml = File.read(Rails.root.join('config/database.yml'))
    expect(database_yml).to include('production:')
    expect(database_yml).to include('url: <%= ENV["DATABASE_URL"] %>')
  end

  it 'CORS initializer が存在し CORS_ORIGINS を参照する' do
    cors_path = Rails.root.join('config/initializers/cors.rb')
    expect(File.exist?(cors_path)).to be(true)

    cors_text = File.read(cors_path)
    expect(cors_text).to include('Rack::Cors')
    expect(cors_text).to include('CORS_ORIGINS')
  end

  it 'production で force_ssl が有効' do
    production_rb = File.read(Rails.root.join('config/environments/production.rb'))
    expect(production_rb).to include('config.force_ssl = true')
  end
end
