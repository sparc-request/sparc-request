desc "Specific task to fix deleted ssrs for protocol 7808"
task restore_ssr_data: :environment do

  protocol = Protocol.find(7808)
  service_request = ServiceRequest.where(protocol_id: protocol.id).first

  ssr1 = SubServiceRequest.create(service_request_id: service_request.id, organization_id: 1,
        owner_id: 15804, ssr_id: "0001", status_date: nil, status: "complete", created_at: "2014-08-05 14:25:02",
        updated_at: "2017-04-27 21:19:25", deleted_at: nil, consult_arranged_date: nil, requester_contacted_date: nil,
        nursing_nutrition_approved: false, lab_approved: false, imaging_approved: false, committee_approved: false,
        in_work_fulfillment: false, routing: nil, org_tree_display: "SCTR/Biostatistics, Design, & Epidemiology",
        service_requester_id: 28285, submitted_at: "2014-08-05 14:25:44", protocol_id: protocol.id)
  
  ssr1_line_item = LineItem.create(service_request_id: service_request.id, sub_service_request_id: ssr1.id, service_id: 4, optional: true, quantity: 1,
                                 complete_date: nil, in_process_date: nil, created_at: "2014-08-05 14:25:02",
                                 updated_at: "2017-04-27 21:19:25", deleted_at: nil, units_per_quantity: 1)
  arm = Arm.create(name: "ARM 1", visit_count: 3, created_at: "2014-08-05 14:21:19", updated_at: "2016-11-04 20:34:39",
                        subject_count: 20, protocol_id: protocol.id, new_with_draft: true, minimum_visit_count: 3, minimum_subject_count: 20)

  visit_group1 = VisitGroup.create(name: "Visit 1", arm_id: arm.id, created_at: "2014-08-05 14:21:19",
                                        updated_at: "2014-12-17 19:02:25", position: 1, day: 1, window_before: 1, window_after: 1)
  visit_group2 = VisitGroup.create(name: "Visit 2", arm_id: arm.id, created_at: "2014-10-28 17:25:54",
                                        updated_at: "2014-12-17 19:03:18", position: 2, day: 10, window_before: 10, window_after: 10)
  visit_group3 = VisitGroup.create(name: "Unscheduled", arm_id: arm.id, created_at: "2015-06-15 12:57:25",
                                        updated_at: "2015-06-15 12:57:25", position: 3, day: 11, window_before: 11, window_after: 11)

  ssr2 = SubServiceRequest.create(service_request_id: service_request.id, organization_id: 58, owner_id: nil, ssr_id: "0002", status_date: nil,
         status: "submitted", created_at: "2014-10-28 15:52:51", updated_at: "2017-04-27 21:19:25", deleted_at: nil,
         consult_arranged_date: nil, requester_contacted_date: nil, nursing_nutrition_approved: false, lab_approved: false,
         imaging_approved: false, committee_approved: false, in_work_fulfillment: false, routing: nil,
         org_tree_display: "Laboratory Services/Clinical Neurobiology Lab", service_requester_id: 28285,
         submitted_at: "2014-10-28 15:55:07", protocol_id: protocol.id)
  ssr2_line_item1 = LineItem.create(service_request_id: service_request.id, sub_service_request_id: ssr2.id, service_id: 475, optional: true,
                                    quantity: nil, complete_date: nil, in_process_date: nil, created_at: "2014-10-28 15:52:51",
                                    updated_at: "2017-04-27 21:19:25", deleted_at: nil, units_per_quantity: 1)
  ssr2_liv1 = LineItemsVisit.create(arm_id: arm.id, line_item_id: ssr2_line_item1.id, subject_count: 20, created_at: "2014-10-28 17:25:28",
                                   updated_at: "2014-10-28 17:25:54")
  ssr2_line_item2 = LineItem.create(service_request_id: service_request.id, sub_service_request_id: ssr2.id, service_id: 3338, optional: false,
                                    quantity: nil, complete_date: nil, in_process_date: nil, created_at: "2014-10-28 15:52:51",
                                    updated_at: "2017-04-27 21:19:25", deleted_at: nil, units_per_quantity: 1)
  ssr2_liv2 = LineItemsVisit.create(arm_id: arm.id, line_item_id: ssr2_line_item2.id, subject_count: 20, created_at: "2014-10-28 17:25:28",
                                    updated_at: "2014-10-28 17:25:54")
  ssr2_visit1 = Visit.create(quantity: 1, billing: nil, created_at: "2014-10-28 17:25:28", updated_at: "2014-10-28 17:26:41",
                             deleted_at: nil, research_billing_qty: 1, insurance_billing_qty: 0, effort_billing_qty: 0,
                             line_items_visit_id: ssr2_liv1.id, visit_group_id: visit_group1.id)
  ssr2_visit2 = Visit.create(quantity: 1, billing: nil, created_at: "2014-10-28 17:25:54", updated_at: "2014-10-28 17:26:45",
                             deleted_at: nil, research_billing_qty: 1, insurance_billing_qty: 0, effort_billing_qty: 0,
                            line_items_visit_id: ssr2_liv1.id, visit_group_id: visit_group2.id)
  ssr2_visit3 = Visit.create(quantity: 0, billing: nil, created_at: "2015-06-15 12:57:25", updated_at: "2015-06-15 12:57:25",
                             deleted_at: nil, research_billing_qty: 0, insurance_billing_qty: 0, effort_billing_qty: 0,
                             line_items_visit_id: ssr2_liv1.id, visit_group_id: visit_group3.id)
  ssr2_visit4 = Visit.create(quantity: 1, billing: nil, created_at: "2014-10-28 17:25:28", updated_at: "2014-10-28 17:26:41",
                             deleted_at: nil, research_billing_qty: 1, insurance_billing_qty: 0, effort_billing_qty: 0,
                             line_items_visit_id: ssr2_liv2.id, visit_group_id: visit_group1.id)
  ssr2_visit5 = Visit.create(quantity: 1, billing: nil, created_at: "2014-10-28 17:25:54", updated_at: "2014-10-28 17:26:45",
                             deleted_at: nil, research_billing_qty: 1, insurance_billing_qty: 0, effort_billing_qty: 0,
                            line_items_visit_id: ssr2_liv2.id, visit_group_id: visit_group2.id)
  ssr2_visit6 = Visit.create(quantity: 0, billing: nil, created_at: "2015-06-15 12:57:25", updated_at: "2015-06-15 12:57:25",
                             deleted_at: nil, research_billing_qty: 0, insurance_billing_qty: 0, effort_billing_qty: 0,
                             line_items_visit_id: ssr2_liv2.id, visit_group_id: visit_group3.id)
end