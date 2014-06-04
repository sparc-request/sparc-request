require 'tempfile'

namespace :email do
  desc "Generate Admin Email For Visual Approval"
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

  desc "Generate Service Provider Email For Visual Approval"
  task :notify_service_provider => :environment do

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

    attachments = {}
    attachments["doc.xls"] = xls

    sr.sub_service_requests.each do |sub_service_request|
      sub_service_request.organization.service_providers.where("(`service_providers`.`hold_emails` != 1 OR `service_providers`.`hold_emails` IS NULL)").each do |service_provider|
        Notifier.notify_service_provider(service_provider, sr, attachments, identity).deliver
      end
    end
    

    xls.unlink
  end  

  desc "Generate User Email For Visual Approval"
  task :notify_user => :environment do

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

    approval = false

    sr.protocol.project_roles.each do |project_role|
      next if project_role.project_rights == 'none'
      Notifier.notify_user(project_role, sr, xls, approval, identity).deliver unless project_role.identity.email.blank?
    end  
    xls.unlink
  end  

  desc "Generate Email of SubService Request Deletion For Visual Approval"
  task :sub_service_request_deleted => :environment do

    def prompt(*args)
      print(*args)
      STDIN.gets.strip
    end

    sr_id = prompt("What service request would you like to use for this email? ")
    sr = ServiceRequest.find(sr_id.to_i)
    identity = Identity.find_by_id(prompt("What user id would you like to use? "))

    sr.sub_service_requests.each do |ssr|
      Notifier.sub_service_request_deleted(identity, ssr, identity).deliver
    end
  end  


end


