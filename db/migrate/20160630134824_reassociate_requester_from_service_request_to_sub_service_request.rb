class ReassociateRequesterFromServiceRequestToSubServiceRequest < ActiveRecord::Migration
  def change

    add_column :sub_service_requests, :service_requester_id, :integer
    add_index :sub_service_requests, :service_requester_id

    ServiceRequest.where.not(service_requester_id: nil).each do |sr|
      sr.sub_service_requests.update_all(service_requester_id: sr.service_requester_id)
    end

    remove_column :service_requests, :service_requester_id
    remove_column :service_requests, :requester_contacted_date
  end
end
