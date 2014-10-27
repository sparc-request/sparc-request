ALTER TABLE affiliations ADD CONSTRAINT Fk_0 FOREIGN KEY(protocol_id)  REFERENCES protocols (id) ;
ALTER TABLE answers ADD CONSTRAINT Fk_1 FOREIGN KEY(question_id)  REFERENCES questions (id) ;
ALTER TABLE appointments ADD CONSTRAINT Fk_2 FOREIGN KEY(visit_group_id)  REFERENCES visit_groups (id) ;
ALTER TABLE appointments ADD CONSTRAINT Fk_3 FOREIGN KEY(calendar_id)  REFERENCES calendars (id) ;
ALTER TABLE appointments ADD CONSTRAINT Fk_4 FOREIGN KEY(organization_id)  REFERENCES organizations (id) ;
ALTER TABLE approvals ADD CONSTRAINT Fk_5 FOREIGN KEY(service_request_id)  REFERENCES service_requests (id) ;
ALTER TABLE approvals ADD CONSTRAINT Fk_6 FOREIGN KEY(identity_id)  REFERENCES identities (id) ;
ALTER TABLE approvals ADD CONSTRAINT Fk_7 FOREIGN KEY(sub_service_request_id)  REFERENCES sub_service_requests (id) ;
ALTER TABLE associated_surveys ADD CONSTRAINT Fk_9 FOREIGN KEY(survey_id)  REFERENCES surveys (id) ;
ALTER TABLE available_statuses ADD CONSTRAINT Fk_10 FOREIGN KEY(organization_id)  REFERENCES organizations (id) ;
ALTER TABLE calendars ADD CONSTRAINT Fk_11 FOREIGN KEY(subject_id)  REFERENCES subjects (id) ;
ALTER TABLE catalog_managers ADD CONSTRAINT Fk_12 FOREIGN KEY(organization_id)  REFERENCES organizations (id) ;
ALTER TABLE catalog_managers ADD CONSTRAINT Fk_13 FOREIGN KEY(identity_id)  REFERENCES identities (id) ;
ALTER TABLE charges ADD CONSTRAINT Fk_14 FOREIGN KEY(service_id)  REFERENCES services (id) ;
ALTER TABLE clinical_providers ADD CONSTRAINT Fk_15 FOREIGN KEY(organization_id)  REFERENCES organizations (id) ;
ALTER TABLE clinical_providers ADD CONSTRAINT Fk_16 FOREIGN KEY(identity_id)  REFERENCES identities (id) ;
ALTER TABLE cover_letters ADD CONSTRAINT Fk_17 FOREIGN KEY(sub_service_request_id)  REFERENCES sub_service_requests (id) ;
ALTER TABLE dependencies ADD CONSTRAINT Fk_18 FOREIGN KEY(question_id)  REFERENCES questions (id) ;
ALTER TABLE dependencies ADD CONSTRAINT Fk_19 FOREIGN KEY(question_group_id)  REFERENCES question_groups (id) ;
ALTER TABLE dependency_conditions ADD CONSTRAINT Fk_20 FOREIGN KEY(dependency_id)  REFERENCES dependencies (id) ;
ALTER TABLE dependency_conditions ADD CONSTRAINT Fk_21 FOREIGN KEY(question_id)  REFERENCES questions (id) ;
ALTER TABLE dependency_conditions ADD CONSTRAINT Fk_22 FOREIGN KEY(answer_id)  REFERENCES answers (id) ;
ALTER TABLE document_groupings ADD CONSTRAINT Fk_25 FOREIGN KEY(service_request_id)  REFERENCES service_requests (id) ;
ALTER TABLE documents ADD CONSTRAINT Fk_23 FOREIGN KEY(sub_service_request_id)  REFERENCES sub_service_requests (id) ;
ALTER TABLE documents ADD CONSTRAINT Fk_24 FOREIGN KEY(document_grouping_id)  REFERENCES document_groupings (id) ;
ALTER TABLE excluded_funding_sources ADD CONSTRAINT Fk_26 FOREIGN KEY(subsidy_map_id)  REFERENCES subsidy_maps (id) ;
ALTER TABLE fulfillments ADD CONSTRAINT Fk_27 FOREIGN KEY(line_item_id)  REFERENCES line_items (id) ;
ALTER TABLE human_subjects_info ADD CONSTRAINT Fk_28 FOREIGN KEY(protocol_id)  REFERENCES protocols (id) ;
ALTER TABLE impact_areas ADD CONSTRAINT Fk_29 FOREIGN KEY(protocol_id)  REFERENCES protocols (id) ;
ALTER TABLE investigational_products_info ADD CONSTRAINT Fk_30 FOREIGN KEY(protocol_id)  REFERENCES protocols (id) ;
ALTER TABLE ip_patents_info ADD CONSTRAINT Fk_31 FOREIGN KEY(protocol_id)  REFERENCES protocols (id) ;
ALTER TABLE line_items ADD CONSTRAINT Fk_32 FOREIGN KEY(service_request_id)  REFERENCES service_requests (id) ;
ALTER TABLE line_items ADD CONSTRAINT Fk_33 FOREIGN KEY(sub_service_request_id)  REFERENCES sub_service_requests (id) ;
ALTER TABLE line_items ADD CONSTRAINT Fk_34 FOREIGN KEY(service_id)  REFERENCES services (id) ;
ALTER TABLE line_items_visits ADD CONSTRAINT Fk_36 FOREIGN KEY(arm_id)  REFERENCES arms (id) ;
ALTER TABLE line_items_visits ADD CONSTRAINT Fk_37 FOREIGN KEY(line_item_id)  REFERENCES line_items (id) ;
ALTER TABLE messages ADD CONSTRAINT Fk_38 FOREIGN KEY(notification_id)  REFERENCES notifications (id) ;
ALTER TABLE notes ADD CONSTRAINT Fk_39 FOREIGN KEY(identity_id)  REFERENCES identities (id) ;
ALTER TABLE notes ADD CONSTRAINT Fk_40 FOREIGN KEY(sub_service_request_id)  REFERENCES sub_service_requests (id) ;
ALTER TABLE notifications ADD CONSTRAINT Fk_41 FOREIGN KEY(sub_service_request_id)  REFERENCES sub_service_requests (id) ;
ALTER TABLE notifications ADD CONSTRAINT FK_notifications_identities FOREIGN KEY(originator_id)  REFERENCES identities (id) ;
ALTER TABLE organizations ADD CONSTRAINT FK_organizations_organizations FOREIGN KEY(parent_id)  REFERENCES organizations (id) ;
ALTER TABLE past_statuses ADD CONSTRAINT Fk_44 FOREIGN KEY(sub_service_request_id)  REFERENCES sub_service_requests (id) ;
ALTER TABLE payment_uploads ADD CONSTRAINT Fk_46 FOREIGN KEY(payment_id)  REFERENCES payments (id) ;
ALTER TABLE payments ADD CONSTRAINT Fk_45 FOREIGN KEY(sub_service_request_id)  REFERENCES sub_service_requests (id) ;
ALTER TABLE pricing_maps ADD CONSTRAINT Fk_47 FOREIGN KEY(service_id)  REFERENCES services (id) ;
ALTER TABLE pricing_setups ADD CONSTRAINT Fk_48 FOREIGN KEY(organization_id)  REFERENCES organizations (id) ;
ALTER TABLE procedures ADD CONSTRAINT Fk_49 FOREIGN KEY(appointment_id)  REFERENCES appointments (id) ;
ALTER TABLE procedures ADD CONSTRAINT Fk_50 FOREIGN KEY(visit_id)  REFERENCES visits (id) ;
ALTER TABLE procedures ADD CONSTRAINT Fk_51 FOREIGN KEY(line_item_id)  REFERENCES line_items (id) ;
ALTER TABLE project_roles ADD CONSTRAINT Fk_52 FOREIGN KEY(protocol_id)  REFERENCES protocols (id) ;
ALTER TABLE project_roles ADD CONSTRAINT Fk_53 FOREIGN KEY(identity_id)  REFERENCES identities (id) ;
ALTER TABLE questions ADD CONSTRAINT Fk_55 FOREIGN KEY(survey_section_id)  REFERENCES survey_sections (id) ;
ALTER TABLE questions ADD CONSTRAINT Fk_56 FOREIGN KEY(question_group_id)  REFERENCES question_groups (id) ;
ALTER TABLE research_types_info ADD CONSTRAINT Fk_58 FOREIGN KEY(protocol_id)  REFERENCES protocols (id) ;
ALTER TABLE response_sets ADD CONSTRAINT Fk_63 FOREIGN KEY(survey_id)  REFERENCES surveys (id) ;
ALTER TABLE responses ADD CONSTRAINT Fk_59 FOREIGN KEY(survey_section_id)  REFERENCES survey_sections (id) ;
ALTER TABLE responses ADD CONSTRAINT Fk_60 FOREIGN KEY(response_set_id)  REFERENCES response_sets (id) ;
ALTER TABLE responses ADD CONSTRAINT Fk_61 FOREIGN KEY(question_id)  REFERENCES questions (id) ;
ALTER TABLE responses ADD CONSTRAINT Fk_62 FOREIGN KEY(answer_id)  REFERENCES answers (id) ;
ALTER TABLE service_providers ADD CONSTRAINT Fk_65 FOREIGN KEY(organization_id)  REFERENCES organizations (id) ;
ALTER TABLE service_providers ADD CONSTRAINT Fk_66 FOREIGN KEY(service_id)  REFERENCES services (id) ;
ALTER TABLE service_providers ADD CONSTRAINT Fk_67 FOREIGN KEY(identity_id)  REFERENCES identities (id) ;
ALTER TABLE service_relations ADD CONSTRAINT Fk_68 FOREIGN KEY(service_id)  REFERENCES services (id) ;
ALTER TABLE service_relations ADD CONSTRAINT Fk_69 FOREIGN KEY(related_service_id)  REFERENCES services (id) ;
ALTER TABLE services ADD CONSTRAINT Fk_64 FOREIGN KEY(organization_id)  REFERENCES organizations (id) ;
ALTER TABLE study_types ADD CONSTRAINT Fk_73 FOREIGN KEY(protocol_id)  REFERENCES protocols (id) ;
ALTER TABLE sub_service_requests ADD CONSTRAINT Fk_78 FOREIGN KEY(service_request_id)  REFERENCES service_requests (id) ;
ALTER TABLE sub_service_requests ADD CONSTRAINT Fk_79 FOREIGN KEY(organization_id)  REFERENCES organizations (id) ;
ALTER TABLE subjects ADD CONSTRAINT Fk_74 FOREIGN KEY(arm_id)  REFERENCES arms (id) ;
ALTER TABLE submission_emails ADD CONSTRAINT Fk_75 FOREIGN KEY(organization_id)  REFERENCES organizations (id) ;
ALTER TABLE subsidies ADD CONSTRAINT Fk_76 FOREIGN KEY(sub_service_request_id)  REFERENCES sub_service_requests (id) ;
ALTER TABLE subsidy_maps ADD CONSTRAINT Fk_77 FOREIGN KEY(organization_id)  REFERENCES organizations (id) ;
ALTER TABLE super_users ADD CONSTRAINT Fk_82 FOREIGN KEY(organization_id)  REFERENCES organizations (id) ;
ALTER TABLE survey_sections ADD CONSTRAINT Fk_84 FOREIGN KEY(survey_id)  REFERENCES surveys (id) ;
ALTER TABLE survey_translations ADD CONSTRAINT Fk_85 FOREIGN KEY(survey_id)  REFERENCES surveys (id) ;
ALTER TABLE taggings ADD CONSTRAINT Fk_86 FOREIGN KEY(tag_id)  REFERENCES tags (id) ;
ALTER TABLE tokens ADD CONSTRAINT Fk_89 FOREIGN KEY(service_request_id)  REFERENCES service_requests (id) ;
ALTER TABLE tokens ADD CONSTRAINT Fk_90 FOREIGN KEY(identity_id)  REFERENCES identities (id) ;
ALTER TABLE user_notifications ADD CONSTRAINT Fk_91 FOREIGN KEY(identity_id)  REFERENCES identities (id) ;
ALTER TABLE user_notifications ADD CONSTRAINT Fk_92 FOREIGN KEY(notification_id)  REFERENCES notifications (id) ;
ALTER TABLE validation_conditions ADD CONSTRAINT Fk_94 FOREIGN KEY(validation_id)  REFERENCES validations (id) ;
ALTER TABLE validation_conditions ADD CONSTRAINT Fk_95 FOREIGN KEY(question_id)  REFERENCES questions (id) ;
ALTER TABLE validation_conditions ADD CONSTRAINT Fk_96 FOREIGN KEY(answer_id)  REFERENCES answers (id) ;
ALTER TABLE validations ADD CONSTRAINT Fk_93 FOREIGN KEY(answer_id)  REFERENCES answers (id) ;
ALTER TABLE visit_groups ADD CONSTRAINT Fk_100 FOREIGN KEY(arm_id)  REFERENCES arms (id) ;
ALTER TABLE visits ADD CONSTRAINT Fk_98 FOREIGN KEY(line_items_visit_id)  REFERENCES line_items_visits (id) ;
ALTER TABLE visits ADD CONSTRAINT Fk_99 FOREIGN KEY(visit_group_id)  REFERENCES visit_groups (id) ;
ALTER TABLE toast_messages ADD CONSTRAINT Fk_toast_messages_from FOREIGN KEY(`from`)  REFERENCES identities (id) ;
ALTER TABLE toast_messages ADD CONSTRAINT Fk_toast_messages_to FOREIGN KEY(`to`)  REFERENCES identities (id) ;
ALTER TABLE admin_rates ADD CONSTRAINT Fk_admin_rates_line_item_id FOREIGN KEY(line_item_id)  REFERENCES line_items (id) ;
ALTER TABLE arms ADD CONSTRAINT Fk_arms_protocol_id FOREIGN KEY(protocol_id) REFERENCES protocols (id) ;
ALTER TABLE charges ADD CONSTRAINT Fk_charges_service_request_id FOREIGN KEY(service_request_id) REFERENCES service_requests (id) ;
ALTER TABLE epic_queues ADD CONSTRAINT Fk_epic_queues_protocol_id FOREIGN KEY(protocol_id) REFERENCES protocols (id) ;
ALTER TABLE epic_rights ADD CONSTRAINT Fk_epic_rights_project_role_id FOREIGN KEY(project_role_id) REFERENCES project_roles (id) ;
ALTER TABLE messages ADD CONSTRAINT Fk_messages_from FOREIGN KEY(`from`)  REFERENCES identities (id) ;
ALTER TABLE messages ADD CONSTRAINT Fk_messages_to FOREIGN KEY(`to`)  REFERENCES identities (id) ;
ALTER TABLE notes ADD CONSTRAINT Fk_notes_appointment_id FOREIGN KEY(appointment_id)  REFERENCES appointments (id) ;
ALTER TABLE procedures ADD CONSTRAINT Fk_procedures_service_id FOREIGN KEY(service_id)  REFERENCES services (id) ;
ALTER TABLE reports ADD CONSTRAINT Fk_reports_sub_service_request_id FOREIGN KEY(sub_service_request_id)  REFERENCES sub_service_requests (id) ;
ALTER TABLE response_sets ADD CONSTRAINT Fk_response_sets_identity_id FOREIGN KEY(user_id)  REFERENCES identities (id) ;
ALTER TABLE super_users ADD CONSTRAINT Fk_super_users_identity_id FOREIGN KEY(identity_id)  REFERENCES identities (id) ;
ALTER TABLE vertebrate_animals_info ADD CONSTRAINT Fk_vertebrate_animals_info_protocol_id FOREIGN KEY(protocol_id)  REFERENCES protocols (id) ;
/*
  These three break the RSpec features tests if running against MySQL database (Robert Miller).
*/
  ALTER TABLE service_requests ADD CONSTRAINT FK_service_requests_protocol_id FOREIGN KEY(protocol_id) REFERENCES protocols (id) ;
  ALTER TABLE service_requests ADD CONSTRAINT FK_service_requests_identities FOREIGN KEY(service_requester_id) REFERENCES identities (id) ;
  ALTER TABLE sub_service_requests ADD CONSTRAINT FK_sub_service_requests_identities FOREIGN KEY(owner_id) REFERENCES identities (id) ;
/*
  Tables without foreign key constraints: audits [because it seems to record every page view with or without data]
*/
/* the following query should return 106 rows:
select *
from INFORMATION_SCHEMA.TABLE_CONSTRAINTS
where CONSTRAINT_TYPE = 'FOREIGN KEY'
 */


