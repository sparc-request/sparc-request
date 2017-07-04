# https://github.com/javan/whenever
every 1.week, at: '12:00am' do
  rake 'remove_historical_first_draft'
end

every 1.day, :at => '4:30 am' do
  rake "update_protocol_with_validated_rm"
end
