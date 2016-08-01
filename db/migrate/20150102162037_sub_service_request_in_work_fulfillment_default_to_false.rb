# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class SubServiceRequestInWorkFulfillmentDefaultToFalse < ActiveRecord::Migration
  def up
    change_column :sub_service_requests, :in_work_fulfillment, :boolean, default: false

    SubServiceRequest.where('in_work_fulfillment IS NULL').update_all in_work_fulfillment: false
  end

  def down
    change_column :sub_service_requests, :in_work_fulfillment, :boolean
  end
end
