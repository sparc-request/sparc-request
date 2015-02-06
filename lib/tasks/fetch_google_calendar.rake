require 'open-uri'

desc "Download the iCal version of the google calendar"
task :fetch_google_calendar => :environment do
  if USE_GOOGLE_CALENDAR
    open(Rails.root.join("tmp", "basic.ics"), "wb") do |file|
      file << open(CALENDAR_URL).read
    end
  end
end
