require 'open-uri'

desc "Download the iCal version of the google calendar"
task :fetch_google_calendar => :environment do
  open(Rails.root.join("tmp", "basic.ics"), "wb") do |file|
    file << open("https://www.google.com/calendar/ical/sparcrequest%40gmail.com/public/basic.ics").read
  end
end