# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130522145154) do

  create_table "affiliations", :force => true do |t|
    t.integer  "protocol_id"
    t.string   "name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.datetime "deleted_at"
  end

  add_index "affiliations", ["protocol_id"], :name => "index_affiliations_on_protocol_id"

  create_table "appointments", :force => true do |t|
    t.integer  "calendar_id"
    t.datetime "completed_at"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "visit_group_id"
  end

  create_table "approvals", :force => true do |t|
    t.integer  "service_request_id"
    t.integer  "identity_id"
    t.datetime "approval_date"
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
    t.datetime "deleted_at"
    t.string   "approval_type",          :default => "Resource Approval"
    t.integer  "sub_service_request_id"
  end

  add_index "approvals", ["service_request_id"], :name => "index_approvals_on_service_request_id"

  create_table "arms", :force => true do |t|
    t.string   "name"
    t.integer  "visit_count"
    t.integer  "service_request_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "subject_count"
  end

  create_table "arms_line_items", :force => true do |t|
    t.integer  "subject_count"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "available_statuses", :force => true do |t|
    t.integer  "organization_id"
    t.string   "status"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "available_statuses", ["organization_id"], :name => "index_available_statuses_on_organization_id"

  create_table "calendars", :force => true do |t|
    t.integer  "subject_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "catalog_managers", :force => true do |t|
    t.integer  "identity_id"
    t.integer  "organization_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.datetime "deleted_at"
    t.boolean  "edit_historic_data"
  end

  add_index "catalog_managers", ["identity_id"], :name => "index_catalog_managers_on_identity_id"
  add_index "catalog_managers", ["organization_id"], :name => "index_catalog_managers_on_organization_id"

  create_table "charges", :force => true do |t|
    t.integer  "service_request_id"
    t.integer  "service_id"
    t.decimal  "charge_amount",      :precision => 12, :scale => 4
    t.datetime "created_at",                                        :null => false
    t.datetime "updated_at",                                        :null => false
    t.datetime "deleted_at"
  end

  add_index "charges", ["service_request_id"], :name => "index_charges_on_service_request_id"

  create_table "clinical_providers", :force => true do |t|
    t.integer  "identity_id"
    t.integer  "organization_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  add_index "clinical_providers", ["organization_id"], :name => "index_clinical_providers_on_organization_id"

  create_table "document_groupings", :force => true do |t|
    t.integer  "service_request_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "documents", :force => true do |t|
    t.integer  "sub_service_request_id"
    t.datetime "deleted_at"
    t.string   "doc_type"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.string   "document_file_name"
    t.string   "document_content_type"
    t.integer  "document_file_size"
    t.datetime "document_updated_at"
    t.integer  "document_grouping_id"
    t.string   "doc_type_other"
  end

  create_table "excluded_funding_sources", :force => true do |t|
    t.integer  "subsidy_map_id"
    t.string   "funding_source"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.datetime "deleted_at"
  end

  add_index "excluded_funding_sources", ["subsidy_map_id"], :name => "index_excluded_funding_sources_on_subsidy_map_id"

  create_table "feedbacks", :force => true do |t|
    t.text     "message"
    t.string   "email"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "fulfillments", :force => true do |t|
    t.integer  "line_item_id"
    t.string   "timeframe"
    t.text     "notes"
    t.string   "time"
    t.datetime "date"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.datetime "deleted_at"
  end

  add_index "fulfillments", ["line_item_id"], :name => "index_fulfillments_on_line_item_id"

  create_table "human_subjects_info", :force => true do |t|
    t.integer  "protocol_id"
    t.string   "hr_number"
    t.string   "pro_number"
    t.string   "irb_of_record"
    t.string   "submission_type"
    t.datetime "irb_approval_date"
    t.datetime "irb_expiration_date"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.datetime "deleted_at"
    t.boolean  "approval_pending"
  end

  add_index "human_subjects_info", ["protocol_id"], :name => "index_human_subjects_info_on_protocol_id"

  create_table "identities", :force => true do |t|
    t.string   "ldap_uid"
    t.string   "obisid"
    t.string   "email"
    t.string   "last_name"
    t.string   "first_name"
    t.string   "institution"
    t.string   "college"
    t.string   "department"
    t.string   "era_commons_name"
    t.string   "credentials"
    t.string   "subspecialty"
    t.string   "phone"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.datetime "deleted_at"
    t.boolean  "catalog_overlord"
    t.string   "credentials_other"
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.text     "reason"
    t.string   "company"
    t.boolean  "approved",               :default => false, :null => false
  end

  add_index "identities", ["approved"], :name => "index_identities_on_approved"
  add_index "identities", ["email"], :name => "index_identities_on_email"
  add_index "identities", ["last_name"], :name => "index_identities_on_last_name"
  add_index "identities", ["ldap_uid"], :name => "index_identities_on_ldap_uid", :unique => true
  add_index "identities", ["obisid"], :name => "index_identities_on_obisid", :unique => true
  add_index "identities", ["reset_password_token"], :name => "index_identities_on_reset_password_token", :unique => true

  create_table "impact_areas", :force => true do |t|
    t.integer  "protocol_id"
    t.string   "name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.datetime "deleted_at"
    t.string   "other_text"
  end

  add_index "impact_areas", ["protocol_id"], :name => "index_impact_areas_on_protocol_id"

  create_table "investigational_products_info", :force => true do |t|
    t.integer  "protocol_id"
    t.string   "ind_number"
    t.boolean  "ind_on_hold"
    t.string   "ide_number"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.datetime "deleted_at"
  end

  add_index "investigational_products_info", ["protocol_id"], :name => "index_investigational_products_info_on_protocol_id"

  create_table "ip_patents_info", :force => true do |t|
    t.integer  "protocol_id"
    t.string   "patent_number"
    t.text     "inventors"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.datetime "deleted_at"
  end

  add_index "ip_patents_info", ["protocol_id"], :name => "index_ip_patents_info_on_protocol_id"

  create_table "line_items", :force => true do |t|
    t.integer  "service_request_id"
    t.integer  "sub_service_request_id"
    t.integer  "service_id"
    t.string   "ssr_id"
    t.boolean  "optional"
    t.integer  "quantity"
    t.datetime "complete_date"
    t.datetime "in_process_date"
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.datetime "deleted_at"
    t.integer  "units_per_quantity",     :default => 1
  end

  add_index "line_items", ["service_request_id"], :name => "index_line_items_on_service_request_id"

  create_table "line_items_visits", :force => true do |t|
    t.integer  "arm_id"
    t.integer  "line_item_id"
    t.integer  "subject_count"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.boolean  "hidden"
  end

  create_table "lookups", :force => true do |t|
    t.integer "new_id"
    t.string  "old_id"
  end

  create_table "messages", :force => true do |t|
    t.integer  "notification_id"
    t.integer  "to"
    t.integer  "from"
    t.string   "email"
    t.string   "subject"
    t.text     "body"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "notes", :force => true do |t|
    t.integer  "identity_id"
    t.integer  "sub_service_request_id"
    t.string   "body"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  create_table "notifications", :force => true do |t|
    t.integer  "sub_service_request_id"
    t.integer  "originator_id"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  create_table "organizations", :force => true do |t|
    t.string   "type"
    t.string   "name"
    t.integer  "order"
    t.string   "css_class"
    t.text     "description"
    t.string   "obisid"
    t.integer  "parent_id"
    t.string   "abbreviation"
    t.text     "ack_language"
    t.boolean  "process_ssrs"
    t.boolean  "is_available"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.datetime "deleted_at"
  end

  add_index "organizations", ["is_available"], :name => "index_organizations_on_is_available"
  add_index "organizations", ["obisid"], :name => "index_organizations_on_obisid"
  add_index "organizations", ["parent_id"], :name => "index_organizations_on_parent_id"

  create_table "past_statuses", :force => true do |t|
    t.integer  "sub_service_request_id"
    t.string   "status"
    t.datetime "date"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.datetime "deleted_at"
  end

  add_index "past_statuses", ["sub_service_request_id"], :name => "index_past_statuses_on_sub_service_request_id"

  create_table "pricing_maps", :force => true do |t|
    t.integer  "service_id"
    t.string   "unit_type"
    t.decimal  "unit_factor",                :precision => 5,  :scale => 2
    t.decimal  "percent_of_fee",             :precision => 5,  :scale => 2
    t.boolean  "is_one_time_fee"
    t.decimal  "full_rate",                  :precision => 12, :scale => 4
    t.boolean  "exclude_from_indirect_cost"
    t.integer  "unit_minimum"
    t.decimal  "federal_rate",               :precision => 12, :scale => 4
    t.decimal  "corporate_rate",             :precision => 12, :scale => 4
    t.date     "effective_date"
    t.datetime "created_at",                                                               :null => false
    t.datetime "updated_at",                                                               :null => false
    t.datetime "deleted_at"
    t.date     "display_date"
    t.decimal  "other_rate",                 :precision => 12, :scale => 4
    t.decimal  "member_rate",                :precision => 12, :scale => 4
    t.integer  "units_per_qty_max",                                         :default => 1
  end

  add_index "pricing_maps", ["service_id"], :name => "index_pricing_maps_on_service_id"

  create_table "pricing_setups", :force => true do |t|
    t.integer  "organization_id"
    t.date     "display_date"
    t.date     "effective_date"
    t.boolean  "charge_master"
    t.decimal  "federal",                :precision => 5, :scale => 2
    t.decimal  "corporate",              :precision => 5, :scale => 2
    t.decimal  "other",                  :precision => 5, :scale => 2
    t.decimal  "member",                 :precision => 5, :scale => 2
    t.string   "college_rate_type"
    t.string   "federal_rate_type"
    t.string   "industry_rate_type"
    t.string   "investigator_rate_type"
    t.string   "internal_rate_type"
    t.string   "foundation_rate_type"
    t.datetime "deleted_at"
  end

  create_table "procedures", :force => true do |t|
    t.integer  "appointment_id"
    t.integer  "visit_id"
    t.integer  "service_id"
    t.boolean  "completed"
    t.boolean  "required"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "line_item_id"
  end

  create_table "project_roles", :force => true do |t|
    t.integer  "protocol_id"
    t.integer  "identity_id"
    t.string   "project_rights"
    t.string   "role"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.datetime "deleted_at"
    t.string   "role_other"
  end

  add_index "project_roles", ["protocol_id"], :name => "index_project_roles_on_protocol_id"

  create_table "protocols", :force => true do |t|
    t.string   "type"
    t.string   "obisid"
    t.integer  "next_ssr_id"
    t.string   "short_title"
    t.text     "title"
    t.string   "sponsor_name"
    t.text     "brief_description"
    t.decimal  "indirect_cost_rate",             :precision => 5, :scale => 2
    t.string   "study_phase"
    t.string   "udak_project_number"
    t.string   "funding_rfa"
    t.string   "funding_status"
    t.string   "potential_funding_source"
    t.datetime "potential_funding_start_date"
    t.string   "funding_source"
    t.datetime "funding_start_date"
    t.string   "federal_grant_serial_number"
    t.string   "federal_grant_title"
    t.string   "federal_grant_code_id"
    t.string   "federal_non_phs_sponsor"
    t.string   "federal_phs_sponsor"
    t.datetime "created_at",                                                   :null => false
    t.datetime "updated_at",                                                   :null => false
    t.datetime "deleted_at"
    t.string   "potential_funding_source_other"
    t.string   "funding_source_other"
  end

  add_index "protocols", ["obisid"], :name => "index_protocols_on_obisid"

  create_table "questions", :force => true do |t|
    t.string   "to"
    t.string   "from"
    t.text     "body"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "research_types_info", :force => true do |t|
    t.integer  "protocol_id"
    t.boolean  "human_subjects"
    t.boolean  "vertebrate_animals"
    t.boolean  "investigational_products"
    t.boolean  "ip_patents"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.datetime "deleted_at"
  end

  add_index "research_types_info", ["protocol_id"], :name => "index_research_types_info_on_protocol_id"

  create_table "service_providers", :force => true do |t|
    t.integer  "identity_id"
    t.integer  "organization_id"
    t.integer  "service_id"
    t.boolean  "is_primary_contact"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.boolean  "hold_emails"
    t.datetime "deleted_at"
  end

  add_index "service_providers", ["organization_id"], :name => "index_service_providers_on_organization_id"
  add_index "service_providers", ["service_id"], :name => "index_service_providers_on_service_id"

  create_table "service_relations", :force => true do |t|
    t.integer  "service_id"
    t.integer  "related_service_id"
    t.boolean  "optional"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.datetime "deleted_at"
  end

  add_index "service_relations", ["service_id"], :name => "index_service_relations_on_service_id"

  create_table "service_requests", :force => true do |t|
    t.integer  "protocol_id"
    t.string   "obisid"
    t.string   "status"
    t.integer  "service_requester_id"
    t.text     "notes"
    t.boolean  "approved"
    t.datetime "start_date"
    t.datetime "end_date"
    t.integer  "subject_count"
    t.datetime "consult_arranged_date"
    t.datetime "pppv_complete_date"
    t.datetime "pppv_in_process_date"
    t.datetime "requester_contacted_date"
    t.datetime "submitted_at"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
    t.datetime "deleted_at"
  end

  add_index "service_requests", ["obisid"], :name => "index_service_requests_on_obisid"
  add_index "service_requests", ["protocol_id"], :name => "index_service_requests_on_protocol_id"
  add_index "service_requests", ["service_requester_id"], :name => "index_service_requests_on_service_requester_id"
  add_index "service_requests", ["status"], :name => "index_service_requests_on_status"

  create_table "services", :force => true do |t|
    t.string   "obisid"
    t.string   "name"
    t.string   "abbreviation"
    t.integer  "order"
    t.text     "description"
    t.boolean  "is_available"
    t.decimal  "service_center_cost", :precision => 12, :scale => 4
    t.string   "cpt_code"
    t.string   "charge_code"
    t.string   "revenue_code"
    t.integer  "organization_id"
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
    t.datetime "deleted_at"
  end

  add_index "services", ["is_available"], :name => "index_services_on_is_available"
  add_index "services", ["obisid"], :name => "index_services_on_obisid"
  add_index "services", ["organization_id"], :name => "index_services_on_organization_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "study_types", :force => true do |t|
    t.integer  "protocol_id"
    t.string   "name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.datetime "deleted_at"
  end

  add_index "study_types", ["protocol_id"], :name => "index_study_types_on_protocol_id"

  create_table "sub_service_requests", :force => true do |t|
    t.integer  "service_request_id"
    t.integer  "organization_id"
    t.integer  "owner_id"
    t.string   "ssr_id"
    t.datetime "status_date"
    t.string   "status"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.datetime "deleted_at"
    t.datetime "consult_arranged_date"
    t.datetime "requester_contacted_date"
    t.boolean  "nursing_nutrition_approved", :default => false
    t.boolean  "lab_approved",               :default => false
    t.boolean  "imaging_approved",           :default => false
    t.boolean  "src_approved",               :default => false
  end

  add_index "sub_service_requests", ["organization_id"], :name => "index_sub_service_requests_on_organization_id"
  add_index "sub_service_requests", ["service_request_id"], :name => "index_sub_service_requests_on_service_request_id"

  create_table "subjects", :force => true do |t|
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.integer  "arm_id"
    t.string   "name"
    t.string   "mrn"
    t.string   "external_subject_id"
    t.date     "dob"
    t.string   "gender"
    t.string   "ethnicity"
  end

  create_table "submission_emails", :force => true do |t|
    t.integer  "organization_id"
    t.string   "email"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.datetime "deleted_at"
  end

  add_index "submission_emails", ["organization_id"], :name => "index_submission_emails_on_organization_id"

  create_table "subsidies", :force => true do |t|
    t.integer  "pi_contribution"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.datetime "deleted_at"
    t.boolean  "overridden"
    t.integer  "sub_service_request_id"
  end

  create_table "subsidy_maps", :force => true do |t|
    t.integer  "organization_id"
    t.decimal  "max_dollar_cap",  :precision => 12, :scale => 4
    t.decimal  "max_percentage",  :precision => 5,  :scale => 2
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.datetime "deleted_at"
  end

  add_index "subsidy_maps", ["organization_id"], :name => "index_subsidy_maps_on_organization_id"

  create_table "super_users", :force => true do |t|
    t.integer  "identity_id"
    t.integer  "organization_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.datetime "deleted_at"
  end

  add_index "super_users", ["organization_id"], :name => "index_super_users_on_organization_id"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "toast_messages", :force => true do |t|
    t.integer  "from"
    t.integer  "to"
    t.string   "sending_class"
    t.integer  "sending_class_id"
    t.string   "message"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "tokens", :force => true do |t|
    t.integer  "service_request_id"
    t.integer  "identity_id"
    t.string   "token"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.datetime "deleted_at"
  end

  add_index "tokens", ["service_request_id"], :name => "index_tokens_on_service_request_id"

  create_table "user_notifications", :force => true do |t|
    t.integer  "identity_id"
    t.integer  "notification_id"
    t.boolean  "read"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "versions", :force => true do |t|
    t.string   "item_type",  :null => false
    t.integer  "item_id",    :null => false
    t.string   "event",      :null => false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], :name => "index_versions_on_item_type_and_item_id"

  create_table "vertebrate_animals_info", :force => true do |t|
    t.integer  "protocol_id"
    t.string   "iacuc_number"
    t.string   "name_of_iacuc"
    t.datetime "iacuc_approval_date"
    t.datetime "iacuc_expiration_date"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.datetime "deleted_at"
  end

  add_index "vertebrate_animals_info", ["protocol_id"], :name => "index_vertebrate_animals_info_on_protocol_id"

  create_table "visit_groups", :force => true do |t|
    t.string   "name"
    t.integer  "arm_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "position"
  end

  add_index "visit_groups", ["arm_id"], :name => "index_visit_groups_on_arm_id"

  create_table "visits", :force => true do |t|
    t.integer  "quantity",              :default => 0
    t.string   "billing"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.datetime "deleted_at"
    t.integer  "research_billing_qty",  :default => 0
    t.integer  "insurance_billing_qty", :default => 0
    t.integer  "effort_billing_qty",    :default => 0
    t.integer  "line_items_visit_id"
    t.integer  "visit_group_id"
  end

end
