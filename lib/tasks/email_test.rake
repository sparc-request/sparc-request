require 'tempfile'

namespace :email do
  desc "Generate Admin Email Per Visual Approval"
  task :notify_admin => :environment do

    def prompt(*args)
      print(*args)
      STDIN.gets.strip
    end

    sr_id = prompt("What service request would you like to use for this email? ")
    sr = ServiceRequest.find(sr_id.to_i)
    identity = Identity.find_by_id(prompt("What user id would you like to use? "))
    
    xls = Tempfile.new('spreadsheet')
    xls.write("i'm a spreadsheet")
    xls.close

    Notifier.notify_admin(sr, "charlie@musc.edu", xls, identity).deliver

    xls.unlink
  end
end