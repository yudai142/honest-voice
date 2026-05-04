set :output, 'log/cron.log'

every 1.day, at: '9:00 am' do
  runner 'RecurringJob.perform_later'
end