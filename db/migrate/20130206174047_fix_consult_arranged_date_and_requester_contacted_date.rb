class FixConsultArrangedDateAndRequesterContactedDate < ActiveRecord::Migration
  def up
    service_requests = ServiceRequest.where("consult_arranged_date is not null or requester_contacted_date is not null")

    count = 0
    service_requests.each do |sr|
      next if sr.sub_service_requests.count > 1

      ssr = sr.sub_service_requests.first
      
      count +=1
      ssr.update_attribute(:consult_arranged_date, sr.consult_arranged_date) if ssr.consult_arranged_date.nil?
      ssr.update_attribute(:requester_contacted_date, sr.requester_contacted_date) if ssr.requester_contacted_date.nil?
    end

    puts "Fixed #{count} sub service requests"
  end

  def down
  end
end
