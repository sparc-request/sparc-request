desc "Specific task to fix deleted ssrs for a protocol"
task restore_ssr_data: :environment do

  protocol = Protocol.find(10890)
  protocol2 = Protocol.find(10888)
  service_request = ServiceRequest.find(1455118)
  service_request2 = ServiceRequest.find(1454933)

  ssr1 = SubServiceRequest.create(service_request_id: service_request.id, organization_id: 11, owner_id: 12910, ssr_id: "0001", status: "ctrc_approved", created_at: "2017-04-26 16:54:01", updated_at: "2017-08-31 18:07:04", deleted_at: nil, nursing_nutrition_approved: false, lab_approved: false, imaging_approved: false, committee_approved: false, in_work_fulfillment: true, routing: nil, org_tree_display: "SCTR/SUCCESS Center/Regulatory Services", service_requester_id: 40521, submitted_at: "2017-04-26 17:11:57", protocol_id: protocol.id)
  
  ssr1_line_item = LineItem.create(service_request_id: service_request.id, sub_service_request_id: ssr1.id, service_id: 8286, optional: true, quantity: 1, complete_date: nil, in_process_date: nil, created_at: "2016-05-31 14:43:10", updated_at: "2017-04-26 16:54:01", deleted_at: nil, units_per_quantity: 1)

  ssr2 = SubServiceRequest.create(service_request_id: service_request2.id, organization_id: 11, owner_id: 22112, ssr_id: "0003", status: "draft", created_at: "2017-08-02 18:55:28", updated_at: "2017-07-11 19:57:48", deleted_at: nil, nursing_nutrition_approved: false, lab_approved: false, imaging_approved: false, committee_approved: false, in_work_fulfillment: true, routing: nil, org_tree_display: "SCTR/SUCCESS Center/Regulatory Services", service_requester_id: 9678, submitted_at: "2017-04-26 18:59:36", protocol_id: protocol2.id)
  
  ssr2_line_item1 = LineItem.create(service_request_id: service_request2.id, sub_service_request_id: ssr2.id, service_id: 8286, optional: true, quantity: 1, complete_date: nil, in_process_date: nil, created_at: "2016-05-31 14:43:10", updated_at: "2017-08-24 18:55:28", deleted_at: nil, units_per_quantity: 1)
  ssr2_line_item2 = LineItem.create(service_request_id: service_request2.id, sub_service_request_id: ssr2.id, service_id: 8287, optional: true, quantity: 1, complete_date: nil, in_process_date: nil, created_at: "2016-05-31 14:43:10", updated_at: "2017-08-24 18:55:28", deleted_at: nil, units_per_quantity: 1)
  ssr2_line_item3 = LineItem.create(service_request_id: service_request2.id, sub_service_request_id: ssr2.id, service_id: 10229, optional: true, quantity: 1, complete_date: nil, in_process_date: nil, created_at: "2016-05-31 14:43:10", updated_at: "2017-08-24 18:55:28", deleted_at: nil, units_per_quantity: 1)

  
  puts "Sub service request #{23896} now has id of #{ssr1.id}"
  puts "Sub service request #{23910} now has id of #{ssr2.id}"
  # arm = Arm.create(name: "ARM 1", visit_count: 3, created_at: "2014-08-05 14:21:19", updated_at: "2016-11-04 20:34:39",
  #                       subject_count: 20, protocol_id: protocol.id, new_with_draft: true, minimum_visit_count: 3, minimum_subject_count: 20)

  # visit_group1 = VisitGroup.create(name: "Visit 1", arm_id: arm.id, created_at: "2014-08-05 14:21:19",
  #                                       updated_at: "2014-12-17 19:02:25", position: 1, day: 1, window_before: 1, window_after: 1)
  # visit_group2 = VisitGroup.create(name: "Visit 2", arm_id: arm.id, created_at: "2014-10-28 17:25:54",
  #                                       updated_at: "2014-12-17 19:03:18", position: 2, day: 10, window_before: 10, window_after: 10)
  # visit_group3 = VisitGroup.create(name: "Unscheduled", arm_id: arm.id, created_at: "2015-06-15 12:57:25",
  #                                       updated_at: "2015-06-15 12:57:25", position: 3, day: 11, window_before: 11, window_after: 11)

  # ssr2 = SubServiceRequest.create(service_request_id: service_request.id, organization_id: 58, owner_id: nil, ssr_id: "0002", status_date: nil,
  #        status: "submitted", created_at: "2014-10-28 15:52:51", updated_at: "2017-04-27 21:19:25", deleted_at: nil,
  #        consult_arranged_date: nil, requester_contacted_date: nil, nursing_nutrition_approved: false, lab_approved: false,
  #        imaging_approved: false, committee_approved: false, in_work_fulfillment: false, routing: nil,
  #        org_tree_display: "Laboratory Services/Clinical Neurobiology Lab", service_requester_id: 28285,
  #        submitted_at: "2014-10-28 15:55:07", protocol_id: protocol.id)
  # ssr2_line_item1 = LineItem.create(service_request_id: service_request.id, sub_service_request_id: ssr2.id, service_id: 475, optional: true,
  #                                   quantity: nil, complete_date: nil, in_process_date: nil, created_at: "2014-10-28 15:52:51",
  #                                   updated_at: "2017-04-27 21:19:25", deleted_at: nil, units_per_quantity: 1)
  # ssr2_liv1 = LineItemsVisit.create(arm_id: arm.id, line_item_id: ssr2_line_item1.id, subject_count: 20, created_at: "2014-10-28 17:25:28",
  #                                  updated_at: "2014-10-28 17:25:54")
  # ssr2_line_item2 = LineItem.create(service_request_id: service_request.id, sub_service_request_id: ssr2.id, service_id: 3338, optional: false,
  #                                   quantity: nil, complete_date: nil, in_process_date: nil, created_at: "2014-10-28 15:52:51",
  #                                   updated_at: "2017-04-27 21:19:25", deleted_at: nil, units_per_quantity: 1)
  # ssr2_liv2 = LineItemsVisit.create(arm_id: arm.id, line_item_id: ssr2_line_item2.id, subject_count: 20, created_at: "2014-10-28 17:25:28",
  #                                   updated_at: "2014-10-28 17:25:54")
  # ssr2_visit1 = Visit.create(quantity: 1, billing: nil, created_at: "2014-10-28 17:25:28", updated_at: "2014-10-28 17:26:41",
  #                            deleted_at: nil, research_billing_qty: 1, insurance_billing_qty: 0, effort_billing_qty: 0,
  #                            line_items_visit_id: ssr2_liv1.id, visit_group_id: visit_group1.id)
  # ssr2_visit2 = Visit.create(quantity: 1, billing: nil, created_at: "2014-10-28 17:25:54", updated_at: "2014-10-28 17:26:45",
  #                            deleted_at: nil, research_billing_qty: 1, insurance_billing_qty: 0, effort_billing_qty: 0,
  #                           line_items_visit_id: ssr2_liv1.id, visit_group_id: visit_group2.id)
  # ssr2_visit3 = Visit.create(quantity: 0, billing: nil, created_at: "2015-06-15 12:57:25", updated_at: "2015-06-15 12:57:25",
  #                            deleted_at: nil, research_billing_qty: 0, insurance_billing_qty: 0, effort_billing_qty: 0,
  #                            line_items_visit_id: ssr2_liv1.id, visit_group_id: visit_group3.id)
  # ssr2_visit4 = Visit.create(quantity: 1, billing: nil, created_at: "2014-10-28 17:25:28", updated_at: "2014-10-28 17:26:41",
  #                            deleted_at: nil, research_billing_qty: 1, insurance_billing_qty: 0, effort_billing_qty: 0,
  #                            line_items_visit_id: ssr2_liv2.id, visit_group_id: visit_group1.id)
  # ssr2_visit5 = Visit.create(quantity: 1, billing: nil, created_at: "2014-10-28 17:25:54", updated_at: "2014-10-28 17:26:45",
  #                            deleted_at: nil, research_billing_qty: 1, insurance_billing_qty: 0, effort_billing_qty: 0,
  #                           line_items_visit_id: ssr2_liv2.id, visit_group_id: visit_group2.id)
  # ssr2_visit6 = Visit.create(quantity: 0, billing: nil, created_at: "2015-06-15 12:57:25", updated_at: "2015-06-15 12:57:25",
  #                            deleted_at: nil, research_billing_qty: 0, insurance_billing_qty: 0, effort_billing_qty: 0,
  #                            line_items_visit_id: ssr2_liv2.id, visit_group_id: visit_group3.id)

  # ssr3 = SubServiceRequest.create(service_request_id: service_request.id, organization_id: 14, owner_id: 6937, ssr_id: "0003",
  #                                 status_date: nil, status: "ctrc_approved", created_at: "2014-10-28 15:55:07",
  #                                 updated_at: "2017-04-28 13:22:22", deleted_at: nil, consult_arranged_date: nil, requester_contacted_date: nil,
  #                                 nursing_nutrition_approved: true, lab_approved: true, imaging_approved: false,
  #                                 committee_approved: false, in_work_fulfillment: true, routing: nil, org_tree_display: "SCTR/Research Nexus",
  #                                 service_requester_id: 28285, submitted_at: "2014-10-28 17:29:24", protocol_id: protocol.id)
  # ssr3_line_item1 = LineItem.create(service_request_id: service_request.id, sub_service_request_id: ssr3.id, service_id: 492, optional: true, quantity: nil,
  #                                   complete_date: nil, in_process_date: nil, created_at: "2014-10-28 15:55:07", updated_at: "2017-04-28 13:22:22",
  #                                   deleted_at: nil, units_per_quantity: 1)
  # ssr3_liv1 = LineItemsVisit.create(arm_id: arm.id, line_item_id: ssr3_line_item1.id, subject_count: 20, created_at: "2014-10-28 17:25:28", updated_at: "2014-10-28 17:25")
  # ssr3_line_item2 = LineItem.create(service_request_id: service_request.id, sub_service_request_id: ssr3.id, service_id: 56, optional: true, quantity: nil,
  #                                   complete_date: nil, in_process_date: nil, created_at: "2014-10-28 17:42:13", updated_at: "2017-04-28 13:22:22",
  #                                   deleted_at: nil, units_per_quantity: 1)
  # ssr3_liv2 = LineItemsVisit.create(arm_id: arm.id, line_item_id: ssr3_line_item2.id, subject_count: 20, created_at: "2014-10-28 17:42:13", updated_at: "2014-10-28 17:42:13")
  # ssr3_line_item3 = LineItem.create(service_request_id: service_request.id, sub_service_request_id: ssr3.id, service_id: 486, optional: true, quantity: nil,
  #                                   complete_date: nil, in_process_date: nil, created_at: "2015-03-03 14:08:07", updated_at: "2017-04-28 13:22:22",
  #                                   deleted_at: nil, units_per_quantity: 1)
  # ssr3_liv3 = LineItemsVisit.create(arm_id: arm.id, line_item_id: ssr3_line_item3.id, subject_count: 20, created_at: "2014-11-04 14:03:12", updated_at: "2015-03-03 14:08:08")
  # ssr3_line_item4 = LineItem.create(service_request_id: service_request.id, sub_service_request_id: ssr3.id, service_id: 98, optional: true, quantity: nil,
  #                                   complete_date: nil, in_process_date: nil, created_at: "2016-11-16 20:51:40", updated_at: "2017-04-28 13:22:23",
  #                                   deleted_at: nil, units_per_quantity: 1)
  # ssr3_liv4 = LineItemsVisit.create(arm_id: arm.id, line_item_id: ssr3_line_item4.id, subject_count: 1, created_at: "2016-11-16 20:51:40", updated_at: "2016-11-18 13:57:06")
  # ssr3_visit1 = Visit.create(quantity: 1, billing: nil, created_at: "2014-10-28 17:25:28", updated_at: "2014-10-28 17:26:41", deleted_at: nil, research_billing_qty: 1,
  #                            insurance_billing_qty: 0, effort_billing_qty: 0, line_items_visit_id: ssr3_liv1.id, visit_group_id: visit_group1.id)
  # ssr3_visit2 = Visit.create(quantity: 1, billing: nil, created_at: "2014-10-28 17:25:54", updated_at: "2014-10-28 17:26:45", deleted_at: nil, research_billing_qty: 1,
  #                            insurance_billing_qty: 0, effort_billing_qty: 0, line_items_visit_id: ssr3_liv1.id, visit_group_id: visit_group2.id)
  # ssr3_visit3 = Visit.create(quantity: 0, billing: nil, created_at: "2015-06-15 12:57:25", updated_at: "2015-06-15 12:57:25", deleted_at: nil, research_billing_qty: 0,
  #                            insurance_billing_qty: 0, effort_billing_qty: 0, line_items_visit_id: ssr3_liv1.id, visit_group_id: visit_group3.id)
  # ssr3_visit4 = Visit.create(quantity: 1, billing: nil, created_at: "2014-10-28 17:42:14", updated_at: "2014-10-28 17:42:17", deleted_at: nil, research_billing_qty: 1,
  #                            insurance_billing_qty: 0, effort_billing_qty: 0, line_items_visit_id: ssr3_liv2.id, visit_group_id: visit_group1.id)
  # ssr3_visit5 = Visit.create(quantity: 1, billing: nil, created_at: "2014-10-28 17:42:14", updated_at: "2014-10-28 17:42:18", deleted_at: nil, research_billing_qty: 1,
  #                            insurance_billing_qty: 0, effort_billing_qty: 0, line_items_visit_id: ssr3_liv2.id, visit_group_id: visit_group2.id)
  # ssr3_visit6 = Visit.create(quantity: 0, billing: nil, created_at: "2015-06-15 12:57:25", updated_at: "2015-06-15 12:57:25", deleted_at: nil, research_billing_qty: 0,
  #                            insurance_billing_qty: 0, effort_billing_qty: 0, line_items_visit_id: ssr3_liv2.id, visit_group_id: visit_group3.id)
  # ssr3_visit7 = Visit.create(quantity: 1, billing: nil, created_at: "2014-11-04 14:03:12", updated_at: "2014-11-04 14:03:16", deleted_at: nil, research_billing_qty: 1,
  #                            insurance_billing_qty: 0, effort_billing_qty: 0, line_items_visit_id: ssr3_liv3.id, visit_group_id: visit_group1.id)
  # ssr3_visit8 = Visit.create(quantity: 1, billing: nil, created_at: "2014-11-04 14:03:12", updated_at: "2014-11-04 14:03:18", deleted_at: nil, research_billing_qty: 1,
  #                            insurance_billing_qty: 0, effort_billing_qty: 0, line_items_visit_id: ssr3_liv3.id, visit_group_id: visit_group2.id)
  # ssr3_visit9 = Visit.create(quantity: 0, billing: nil, created_at: "2015-06-15 12:57:25", updated_at: "2015-06-15 12:57:25", deleted_at: nil, research_billing_qty: 0,
  #                            insurance_billing_qty: 0, effort_billing_qty: 0, line_items_visit_id: ssr3_liv3.id, visit_group_id: visit_group3.id)
  # ssr3_visit10 = Visit.create(quantity: 0, billing: nil, created_at: "2016-11-16 20:51:40", updated_at: "2016-11-16 20:51:40", deleted_at: nil, research_billing_qty: 0,
  #                             insurance_billing_qty: 0, effort_billing_qty: 0, line_items_visit_id: ssr3_liv4.id, visit_group_id: visit_group1.id)
  # ssr3_visit11 = Visit.create(quantity: 1, billing: nil, created_at: "2016-11-16 20:51:40", updated_at: "2016-11-16 20:51:47", deleted_at: nil, research_billing_qty: 1,
  #                             insurance_billing_qty: 0, effort_billing_qty: 0, line_items_visit_id: ssr3_liv4.id, visit_group_id: visit_group2.id)
  # ssr3_visit12 = Visit.create(quantity: 0, billing: nil, created_at: "2016-11-16 20:51:40", updated_at: "2016-11-16 20:51:40", deleted_at: nil, research_billing_qty: 0,
  #                             insurance_billing_qty: 0, effort_billing_qty: 0, line_items_visit_id: ssr3_liv4.id, visit_group_id: visit_group3.id)
  # subsidy = Subsidy.create(created_at: "2016-11-18 14:00:15", updated_at: "2016-11-18 14:00:15", deleted_at: nil, overridden: nil, sub_service_request_id: ssr3.id,
  #                          total_at_approval: 85776, status: "Approved", approved_by: 6937, approved_at: "2016-11-18 14:00:15", percent_subsidy: 0.5)

  # ssr4 = SubServiceRequest.create(service_request_id: service_request.id, organization_id: 1, owner_id: nil, ssr_id: "0005", status_date: nil, status: "draft",
  #                                 created_at: "2016-11-14 16:11:54", updated_at: "2017-04-28 13:22:22", deleted_at: nil, consult_arranged_date: nil, requester_contacted_date: nil,
  #                                 nursing_nutrition_approved: false, lab_approved: false, imaging_approved: false, committee_approved: false, in_work_fulfillment: false,
  #                                 routing: nil, org_tree_display: "SCTR/Biostatistics, Design, & Epidemiology", service_requester_id: 28285, submitted_at: nil, protocol_id: protocol.id)
  # ssr4_line_item = LineItem.create(service_request_id: service_request.id, sub_service_request_id: ssr4.id, service_id: 5, optional: true, quantity: 1, complete_date: nil, in_process_date: nil,
  #                                  created_at: "2016-11-14 16:11:54", updated_at: "2017-04-28 13:22:23", deleted_at: nil, units_per_quantity: 1)
  # note = Note.create(identity_id: 28285, body: "My SCTR pilot project, Augmenting PRolonged Exposure Therapy for PTSD with OXytocin is now complete and ready for data analysis. I couldn't figure out how to connect this request with that study in a SPARC request, so I created a new study.", created_at: "2016-11-14 16:15:50", updated_at: "2017-04-10 12:43:04", notable_id: 7808, notable_type: "Protocol")
  # past_status1 = PastStatus.create(sub_service_request_id: ssr1.id, status: "first_draft", date: "2014-08-05 14:25:44", created_at: "2014-08-05 14:25:44", updated_at: "2016-08-30 15:39:22", deleted_at: nil, changed_by_id: 28285)
  # past_status2 = PastStatus.create(sub_service_request_id: ssr1.id, status: "submitted", date: "2014-08-12 17:31:28", created_at: "2014-08-12 17:31:28", updated_at: "2016-08-30 15:39:24", deleted_at: nil, changed_by_id: 15804)
  # past_status3 = PastStatus.create(sub_service_request_id: ssr2.id, status: "first_draft", date: "2014-10-28 15:55:07", created_at: "2014-10-28 15:55:07", updated_at: "2014-10-28 15:55:07", deleted_at: nil, changed_by_id: nil)
  # past_status4 = PastStatus.create(sub_service_request_id: ssr3.id, status: "first_draft", date: "2014-10-28 17:29:24", created_at: "2014-10-28 17:29:24", updated_at: "2016-08-30 15:39:52", deleted_at: nil, changed_by_id: 28285)
  # past_status5 = PastStatus.create(sub_service_request_id: ssr3.id, status: "submitted", date: "2014-10-28 17:41:55", created_at: "2014-10-28 17:41:55", updated_at: "2016-08-30 15:39:52", deleted_at: nil, changed_by_id: 6937)
  # past_status6 = PastStatus.create(sub_service_request_id: ssr3.id, status: "in_process", date: "2014-11-03 20:08:21", created_at: "2014-11-03 20:08:21", updated_at: "2016-08-30 15:39:54", deleted_at: nil, changed_by_id: 6937)
  # past_status7 = PastStatus.create(sub_service_request_id: ssr3.id, status: "on_hold", date: "2014-11-17 15:59:16", created_at: "2014-11-17 15:59:16", updated_at: "2016-08-30 15:39:58", deleted_at: nil, changed_by_id: 6937)
  # past_status8 = PastStatus.create(sub_service_request_id: ssr3.id, status: "ctrc_approved", date: "2015-03-17 13:36:23", created_at: "2015-03-17 13:36:23", updated_at: "2016-08-30 15:40:43", deleted_at: nil, changed_by_id: 6937)
  # past_status9 = PastStatus.create(sub_service_request_id: ssr3.id, status: "complete", date: "2015-03-19 18:56:29", created_at: "2015-03-19 18:56:29", updated_at: "2016-08-30 15:40:44", deleted_at: nil, changed_by_id: 15885)
  # past_status10 = PastStatus.create(sub_service_request_id: ssr3.id, status: "ctrc_approved", date: "2016-11-03 15:56:53", created_at: "2016-11-03 15:56:53", updated_at: "2016-11-03 15:56:53", deleted_at: nil, changed_by_id: 15885)
  # past_status11 = PastStatus.create(sub_service_request_id: ssr3.id, status: "awaiting_pi_approval", date: "2016-11-17 15:30:11", created_at: "2016-11-17 15:30:11", updated_at: "2016-11-17 15:30:11", deleted_at: nil, changed_by_id: 6937)
  # past_status12 = PastStatus.create(sub_service_request_id: ssr3.id, status: "ctrc_review", date: "2016-11-18 14:00:48", created_at: "2016-11-18 14:00:48", updated_at: "2016-11-18 14:00:48", deleted_at: nil, changed_by_id: 6937)
  # past_status13 = PastStatus.create(sub_service_request_id: ssr3.id, status: "approved", date: "2016-11-18 14:00:51", created_at: "2016-11-18 14:00:51", updated_at: "2016-11-18 14:00:51", deleted_at: nil, changed_by_id: 6937)
end