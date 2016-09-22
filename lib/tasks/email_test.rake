# Copyright © 2011-2016 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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

    sr.previous_submitted_at = sr.submitted_at
    # sr.previous_submitted_at = (Time.now - 1.day)

    previously_submitted_at = sr.previous_submitted_at.nil? ? Time.now.utc : sr.previous_submitted_at.utc
    sr.sub_service_requests.each do |sub_service_request|
      sub_service_request.organization.service_providers.where("(`service_providers`.`hold_emails` != 1 OR `service_providers`.`hold_emails` IS NULL)").each do |service_provider|
        Notifier.notify_service_provider(service_provider, sr, attachments, identity, sub_service_request.audit_report(identity, previously_submitted_at, Time.now.utc)).deliver
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


