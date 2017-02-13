# https://github.com/javan/whenever
every 1.week, at: '12:00am' do
  rake 'remove_historical_first_draft'
end
