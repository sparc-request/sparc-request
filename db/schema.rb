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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160930185037) do

  create_table "admin_rates", force: :cascade do |t|
    t.integer  "line_item_id", limit: 4
    t.integer  "admin_cost",   limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "affiliations", force: :cascade do |t|
    t.integer  "protocol_id", limit: 4
    t.string   "name",        limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.datetime "deleted_at"
  end

  add_index "affiliations", ["protocol_id"], name: "index_affiliations_on_protocol_id", using: :btree

  create_table "alerts", force: :cascade do |t|
    t.string   "alert_type", limit: 255
    t.string   "status",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "answers", force: :cascade do |t|
    t.integer  "question_id",            limit: 4
    t.text     "text",                   limit: 65535
    t.text     "short_text",             limit: 65535
    t.text     "help_text",              limit: 65535
    t.integer  "weight",                 limit: 4
    t.string   "response_class",         limit: 255
    t.string   "reference_identifier",   limit: 255
    t.string   "data_export_identifier", limit: 255
    t.string   "common_namespace",       limit: 255
    t.string   "common_identifier",      limit: 255
    t.integer  "display_order",          limit: 4
    t.boolean  "is_exclusive"
    t.integer  "display_length",         limit: 4
    t.string   "custom_class",           limit: 255
    t.string   "custom_renderer",        limit: 255
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "default_value",          limit: 255
    t.string   "api_id",                 limit: 255
    t.string   "display_type",           limit: 255
    t.string   "input_mask",             limit: 255
    t.string   "input_mask_placeholder", limit: 255
  end

  add_index "answers", ["api_id"], name: "uq_answers_api_id", unique: true, using: :btree
  add_index "answers", ["question_id"], name: "index_answers_on_question_id", using: :btree

  create_table "appointments", force: :cascade do |t|
    t.integer  "calendar_id",     limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "visit_group_id",  limit: 4
    t.integer  "position",        limit: 4
    t.string   "name",            limit: 255
    t.integer  "organization_id", limit: 4
    t.date     "completed_at"
  end

  add_index "appointments", ["calendar_id"], name: "index_appointments_on_calendar_id", using: :btree
  add_index "appointments", ["organization_id"], name: "index_appointments_on_organization_id", using: :btree
  add_index "appointments", ["visit_group_id"], name: "index_appointments_on_visit_group_id", using: :btree

  create_table "approvals", force: :cascade do |t|
    t.integer  "service_request_id",     limit: 4
    t.integer  "identity_id",            limit: 4
    t.datetime "approval_date"
    t.datetime "created_at",                                                       null: false
    t.datetime "updated_at",                                                       null: false
    t.datetime "deleted_at"
    t.string   "approval_type",          limit: 255, default: "Resource Approval"
    t.integer  "sub_service_request_id", limit: 4
  end

  add_index "approvals", ["identity_id"], name: "index_approvals_on_identity_id", using: :btree
  add_index "approvals", ["service_request_id"], name: "index_approvals_on_service_request_id", using: :btree
  add_index "approvals", ["sub_service_request_id"], name: "index_approvals_on_sub_service_request_id", using: :btree

  create_table "arms", force: :cascade do |t|
    t.string   "name",                  limit: 255
    t.integer  "visit_count",           limit: 4,   default: 1
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.integer  "subject_count",         limit: 4,   default: 1
    t.integer  "protocol_id",           limit: 4
    t.boolean  "new_with_draft",                    default: false
    t.integer  "minimum_visit_count",   limit: 4,   default: 0
    t.integer  "minimum_subject_count", limit: 4,   default: 0
  end

  add_index "arms", ["protocol_id"], name: "index_arms_on_protocol_id", using: :btree

  create_table "associated_surveys", force: :cascade do |t|
    t.integer  "surveyable_id",   limit: 4
    t.string   "surveyable_type", limit: 255
    t.integer  "survey_id",       limit: 4
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "associated_surveys", ["survey_id"], name: "index_associated_surveys_on_survey_id", using: :btree
  add_index "associated_surveys", ["surveyable_id"], name: "index_associated_surveys_on_surveyable_id", using: :btree

  create_table "audits", force: :cascade do |t|
    t.integer  "auditable_id",    limit: 4
    t.string   "auditable_type",  limit: 255
    t.integer  "associated_id",   limit: 4
    t.string   "associated_type", limit: 255
    t.integer  "user_id",         limit: 4
    t.string   "user_type",       limit: 255
    t.string   "username",        limit: 255
    t.string   "action",          limit: 255
    t.text     "audited_changes", limit: 65535
    t.integer  "version",         limit: 4,     default: 0
    t.string   "comment",         limit: 255
    t.string   "remote_address",  limit: 255
    t.datetime "created_at"
    t.string   "request_uuid",    limit: 255
  end

  add_index "audits", ["associated_id", "associated_type"], name: "associated_index", using: :btree
  add_index "audits", ["auditable_id", "auditable_type"], name: "auditable_index", using: :btree
  add_index "audits", ["created_at"], name: "index_audits_on_created_at", using: :btree
  add_index "audits", ["request_uuid"], name: "index_audits_on_request_uuid", using: :btree
  add_index "audits", ["user_id", "user_type"], name: "user_index", using: :btree

  create_table "available_statuses", force: :cascade do |t|
    t.integer  "organization_id", limit: 4
    t.string   "status",          limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "available_statuses", ["organization_id"], name: "index_available_statuses_on_organization_id", using: :btree

  create_table "calendars", force: :cascade do |t|
    t.integer  "subject_id", limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "calendars", ["subject_id"], name: "index_calendars_on_subject_id", using: :btree

  create_table "catalog_managers", force: :cascade do |t|
    t.integer  "identity_id",        limit: 4
    t.integer  "organization_id",    limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.datetime "deleted_at"
    t.boolean  "edit_historic_data"
  end

  add_index "catalog_managers", ["identity_id"], name: "index_catalog_managers_on_identity_id", using: :btree
  add_index "catalog_managers", ["organization_id"], name: "index_catalog_managers_on_organization_id", using: :btree

  create_table "charges", force: :cascade do |t|
    t.integer  "service_request_id", limit: 4
    t.integer  "service_id",         limit: 4
    t.decimal  "charge_amount",                precision: 12, scale: 4
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.datetime "deleted_at"
  end

  add_index "charges", ["service_id"], name: "index_charges_on_service_id", using: :btree
  add_index "charges", ["service_request_id"], name: "index_charges_on_service_request_id", using: :btree

  create_table "clinical_providers", force: :cascade do |t|
    t.integer  "identity_id",     limit: 4
    t.integer  "organization_id", limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "clinical_providers", ["identity_id"], name: "index_clinical_providers_on_identity_id", using: :btree
  add_index "clinical_providers", ["organization_id"], name: "index_clinical_providers_on_organization_id", using: :btree

  create_table "contact_forms", force: :cascade do |t|
    t.string   "subject",    limit: 255
    t.string   "email",      limit: 255
    t.text     "message",    limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "cover_letters", force: :cascade do |t|
    t.text     "content",                limit: 65535
    t.integer  "sub_service_request_id", limit: 4
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "cover_letters", ["sub_service_request_id"], name: "index_cover_letters_on_sub_service_request_id", using: :btree

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0, null: false
    t.integer  "attempts",   limit: 4,     default: 0, null: false
    t.text     "handler",    limit: 65535,             null: false
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "dependencies", force: :cascade do |t|
    t.integer  "question_id",       limit: 4
    t.integer  "question_group_id", limit: 4
    t.string   "rule",              limit: 255
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "dependencies", ["question_group_id"], name: "index_dependencies_on_question_group_id", using: :btree
  add_index "dependencies", ["question_id"], name: "index_dependencies_on_question_id", using: :btree

  create_table "dependency_conditions", force: :cascade do |t|
    t.integer  "dependency_id",  limit: 4
    t.string   "rule_key",       limit: 255
    t.integer  "question_id",    limit: 4
    t.string   "operator",       limit: 255
    t.integer  "answer_id",      limit: 4
    t.datetime "datetime_value"
    t.integer  "integer_value",  limit: 4
    t.float    "float_value",    limit: 24
    t.string   "unit",           limit: 255
    t.text     "text_value",     limit: 65535
    t.string   "string_value",   limit: 255
    t.string   "response_other", limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "dependency_conditions", ["answer_id"], name: "index_dependency_conditions_on_answer_id", using: :btree
  add_index "dependency_conditions", ["dependency_id"], name: "index_dependency_conditions_on_dependency_id", using: :btree
  add_index "dependency_conditions", ["question_id"], name: "index_dependency_conditions_on_question_id", using: :btree

  create_table "documents", force: :cascade do |t|
    t.datetime "deleted_at"
    t.string   "doc_type",              limit: 255
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "document_file_name",    limit: 255
    t.string   "document_content_type", limit: 255
    t.integer  "document_file_size",    limit: 4
    t.datetime "document_updated_at"
    t.string   "doc_type_other",        limit: 255
    t.integer  "protocol_id",           limit: 4
  end

  add_index "documents", ["protocol_id"], name: "index_documents_on_protocol_id", using: :btree

  create_table "documents_sub_service_requests", id: false, force: :cascade do |t|
    t.integer "document_id",            limit: 4
    t.integer "sub_service_request_id", limit: 4
  end

  create_table "epic_queue_records", force: :cascade do |t|
    t.integer  "protocol_id", limit: 4
    t.string   "status",      limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "epic_queues", force: :cascade do |t|
    t.integer  "protocol_id", limit: 4
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  create_table "epic_rights", force: :cascade do |t|
    t.integer  "project_role_id", limit: 4
    t.string   "right",           limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "excluded_funding_sources", force: :cascade do |t|
    t.integer  "subsidy_map_id", limit: 4
    t.string   "funding_source", limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.datetime "deleted_at"
  end

  add_index "excluded_funding_sources", ["subsidy_map_id"], name: "index_excluded_funding_sources_on_subsidy_map_id", using: :btree

  create_table "feedbacks", force: :cascade do |t|
    t.text     "message",    limit: 65535
    t.string   "email",      limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "fulfillments", force: :cascade do |t|
    t.integer  "line_item_id",  limit: 4
    t.string   "timeframe",     limit: 255
    t.string   "time",          limit: 255
    t.datetime "date"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.datetime "deleted_at"
    t.string   "unit_type",     limit: 255
    t.string   "quantity_type", limit: 255
    t.integer  "quantity",      limit: 4
    t.integer  "unit_quantity", limit: 4
  end

  add_index "fulfillments", ["line_item_id"], name: "index_fulfillments_on_line_item_id", using: :btree

  create_table "human_subjects_info", force: :cascade do |t|
    t.integer  "protocol_id",         limit: 4
    t.string   "hr_number",           limit: 255
    t.string   "pro_number",          limit: 255
    t.string   "irb_of_record",       limit: 255
    t.string   "submission_type",     limit: 255
    t.datetime "irb_approval_date"
    t.datetime "irb_expiration_date"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.datetime "deleted_at"
    t.boolean  "approval_pending"
    t.string   "nct_number",          limit: 255
  end

  add_index "human_subjects_info", ["protocol_id"], name: "index_human_subjects_info_on_protocol_id", using: :btree

  create_table "identities", force: :cascade do |t|
    t.string   "ldap_uid",               limit: 255
    t.string   "email",                  limit: 255
    t.string   "last_name",              limit: 255
    t.string   "first_name",             limit: 255
    t.string   "institution",            limit: 255
    t.string   "college",                limit: 255
    t.string   "department",             limit: 255
    t.string   "era_commons_name",       limit: 255
    t.string   "credentials",            limit: 255
    t.string   "subspecialty",           limit: 255
    t.string   "phone",                  limit: 255
    t.datetime "created_at",                                                                  null: false
    t.datetime "updated_at",                                                                  null: false
    t.datetime "deleted_at"
    t.boolean  "catalog_overlord"
    t.string   "credentials_other",      limit: 255
    t.string   "encrypted_password",     limit: 255,   default: "",                           null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,     default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.text     "reason",                 limit: 65535
    t.string   "company",                limit: 255
    t.boolean  "approved",                             default: false,                        null: false
    t.string   "time_zone",              limit: 255,   default: "Eastern Time (US & Canada)"
  end

  add_index "identities", ["approved"], name: "index_identities_on_approved", using: :btree
  add_index "identities", ["email"], name: "index_identities_on_email", using: :btree
  add_index "identities", ["last_name"], name: "index_identities_on_last_name", using: :btree
  add_index "identities", ["ldap_uid"], name: "index_identities_on_ldap_uid", unique: true, using: :btree
  add_index "identities", ["reset_password_token"], name: "index_identities_on_reset_password_token", unique: true, using: :btree

  create_table "impact_areas", force: :cascade do |t|
    t.integer  "protocol_id", limit: 4
    t.string   "name",        limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.datetime "deleted_at"
    t.string   "other_text",  limit: 255
  end

  add_index "impact_areas", ["protocol_id"], name: "index_impact_areas_on_protocol_id", using: :btree

  create_table "investigational_products_info", force: :cascade do |t|
    t.integer  "protocol_id",       limit: 4
    t.string   "ind_number",        limit: 255
    t.boolean  "ind_on_hold"
    t.string   "inv_device_number", limit: 255
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.datetime "deleted_at"
    t.string   "exemption_type",    limit: 255, default: ""
  end

  add_index "investigational_products_info", ["protocol_id"], name: "index_investigational_products_info_on_protocol_id", using: :btree

  create_table "ip_patents_info", force: :cascade do |t|
    t.integer  "protocol_id",   limit: 4
    t.string   "patent_number", limit: 255
    t.text     "inventors",     limit: 65535
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.datetime "deleted_at"
  end

  add_index "ip_patents_info", ["protocol_id"], name: "index_ip_patents_info_on_protocol_id", using: :btree

  create_table "item_options", force: :cascade do |t|
    t.string   "content",    limit: 255
    t.integer  "item_id",    limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "item_options", ["item_id"], name: "index_item_options_on_item_id", using: :btree

  create_table "items", force: :cascade do |t|
    t.text     "content",          limit: 65535
    t.string   "item_type",        limit: 255
    t.text     "description",      limit: 65535
    t.boolean  "required"
    t.integer  "questionnaire_id", limit: 4
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "items", ["questionnaire_id"], name: "index_items_on_questionnaire_id", using: :btree

  create_table "line_items", force: :cascade do |t|
    t.integer  "service_request_id",     limit: 4
    t.integer  "sub_service_request_id", limit: 4
    t.integer  "service_id",             limit: 4
    t.string   "ssr_id",                 limit: 255
    t.boolean  "optional",                           default: true
    t.integer  "quantity",               limit: 4
    t.datetime "complete_date"
    t.datetime "in_process_date"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.datetime "deleted_at"
    t.integer  "units_per_quantity",     limit: 4,   default: 1
  end

  add_index "line_items", ["service_id"], name: "index_line_items_on_service_id", using: :btree
  add_index "line_items", ["service_request_id"], name: "index_line_items_on_service_request_id", using: :btree
  add_index "line_items", ["ssr_id"], name: "index_line_items_on_ssr_id", using: :btree
  add_index "line_items", ["sub_service_request_id"], name: "index_line_items_on_sub_service_request_id", using: :btree

  create_table "line_items_visits", force: :cascade do |t|
    t.integer  "arm_id",        limit: 4
    t.integer  "line_item_id",  limit: 4
    t.integer  "subject_count", limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "line_items_visits", ["arm_id"], name: "index_line_items_visits_on_arm_id", using: :btree
  add_index "line_items_visits", ["line_item_id"], name: "index_line_items_visits_on_line_item_id", using: :btree

  create_table "lookups", force: :cascade do |t|
    t.integer "new_id", limit: 4
    t.string  "old_id", limit: 255
  end

  create_table "messages", force: :cascade do |t|
    t.integer  "notification_id", limit: 4
    t.integer  "to",              limit: 4
    t.integer  "from",            limit: 4
    t.string   "email",           limit: 255
    t.text     "body",            limit: 65535
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "messages", ["notification_id"], name: "index_messages_on_notification_id", using: :btree

  create_table "notes", force: :cascade do |t|
    t.integer  "identity_id",  limit: 4
    t.text     "body",         limit: 65535
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "notable_id",   limit: 4
    t.string   "notable_type", limit: 255
  end

  add_index "notes", ["identity_id"], name: "index_notes_on_identity_id", using: :btree
  add_index "notes", ["identity_id"], name: "index_notes_on_user_id", using: :btree
  add_index "notes", ["notable_id", "notable_type"], name: "index_notes_on_notable_id_and_notable_type", using: :btree

  create_table "notifications", force: :cascade do |t|
    t.integer  "sub_service_request_id", limit: 4
    t.integer  "originator_id",          limit: 4
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "subject",                limit: 255
    t.integer  "other_user_id",          limit: 4
    t.boolean  "read_by_originator"
    t.boolean  "read_by_other_user"
  end

  add_index "notifications", ["originator_id"], name: "index_notifications_on_originator_id", using: :btree
  add_index "notifications", ["sub_service_request_id"], name: "index_notifications_on_sub_service_request_id", using: :btree

  create_table "organizations", force: :cascade do |t|
    t.string   "type",         limit: 255
    t.string   "name",         limit: 255
    t.integer  "order",        limit: 4
    t.string   "css_class",    limit: 255,   default: ""
    t.text     "description",  limit: 65535
    t.integer  "parent_id",    limit: 4
    t.string   "abbreviation", limit: 255
    t.text     "ack_language", limit: 65535
    t.boolean  "process_ssrs",               default: false
    t.boolean  "is_available",               default: true
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.datetime "deleted_at"
  end

  add_index "organizations", ["is_available"], name: "index_organizations_on_is_available", using: :btree
  add_index "organizations", ["parent_id"], name: "index_organizations_on_parent_id", using: :btree

  create_table "past_statuses", force: :cascade do |t|
    t.integer  "sub_service_request_id", limit: 4
    t.string   "status",                 limit: 255
    t.datetime "date"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.datetime "deleted_at"
    t.integer  "changed_by_id",          limit: 4
  end

  add_index "past_statuses", ["changed_by_id"], name: "index_past_statuses_on_changed_by_id", using: :btree
  add_index "past_statuses", ["sub_service_request_id"], name: "index_past_statuses_on_sub_service_request_id", using: :btree

  create_table "past_subsidies", force: :cascade do |t|
    t.integer  "sub_service_request_id", limit: 4
    t.integer  "total_at_approval",      limit: 4
    t.integer  "approved_by",            limit: 4
    t.datetime "approved_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "percent_subsidy",        limit: 24, default: 0.0
  end

  add_index "past_subsidies", ["approved_by"], name: "index_past_subsidies_on_approved_by", using: :btree
  add_index "past_subsidies", ["sub_service_request_id"], name: "index_past_subsidies_on_sub_service_request_id", using: :btree

  create_table "payment_uploads", force: :cascade do |t|
    t.integer  "payment_id",        limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "file_file_name",    limit: 255
    t.string   "file_content_type", limit: 255
    t.integer  "file_file_size",    limit: 4
    t.datetime "file_updated_at"
  end

  add_index "payment_uploads", ["payment_id"], name: "index_payment_uploads_on_payment_id", using: :btree

  create_table "payments", force: :cascade do |t|
    t.integer  "sub_service_request_id", limit: 4
    t.date     "date_submitted"
    t.decimal  "amount_invoiced",                      precision: 12, scale: 4
    t.decimal  "amount_received",                      precision: 12, scale: 4
    t.date     "date_received"
    t.string   "payment_method",         limit: 255
    t.text     "details",                limit: 65535
    t.datetime "created_at",                                                    null: false
    t.datetime "updated_at",                                                    null: false
    t.float    "percent_subsidy",        limit: 24
  end

  add_index "payments", ["sub_service_request_id"], name: "index_payments_on_sub_service_request_id", using: :btree

  create_table "pricing_maps", force: :cascade do |t|
    t.integer  "service_id",                 limit: 4
    t.string   "unit_type",                  limit: 255
    t.decimal  "unit_factor",                            precision: 5,  scale: 2
    t.decimal  "percent_of_fee",                         precision: 5,  scale: 2
    t.decimal  "full_rate",                              precision: 12, scale: 4
    t.boolean  "exclude_from_indirect_cost"
    t.integer  "unit_minimum",               limit: 4
    t.decimal  "federal_rate",                           precision: 12, scale: 4
    t.decimal  "corporate_rate",                         precision: 12, scale: 4
    t.date     "effective_date"
    t.datetime "created_at",                                                                      null: false
    t.datetime "updated_at",                                                                      null: false
    t.datetime "deleted_at"
    t.date     "display_date"
    t.decimal  "other_rate",                             precision: 12, scale: 4
    t.decimal  "member_rate",                            precision: 12, scale: 4
    t.integer  "units_per_qty_max",          limit: 4,                            default: 10000
    t.string   "quantity_type",              limit: 255
    t.string   "otf_unit_type",              limit: 255,                          default: "N/A"
    t.integer  "quantity_minimum",           limit: 4,                            default: 1
  end

  add_index "pricing_maps", ["service_id"], name: "index_pricing_maps_on_service_id", using: :btree

  create_table "pricing_setups", force: :cascade do |t|
    t.integer  "organization_id",        limit: 4
    t.date     "display_date"
    t.date     "effective_date"
    t.boolean  "charge_master"
    t.decimal  "federal",                            precision: 5, scale: 2
    t.decimal  "corporate",                          precision: 5, scale: 2
    t.decimal  "other",                              precision: 5, scale: 2
    t.decimal  "member",                             precision: 5, scale: 2
    t.string   "college_rate_type",      limit: 255
    t.string   "federal_rate_type",      limit: 255
    t.string   "industry_rate_type",     limit: 255
    t.string   "investigator_rate_type", limit: 255
    t.string   "internal_rate_type",     limit: 255
    t.string   "foundation_rate_type",   limit: 255
    t.datetime "deleted_at"
    t.string   "unfunded_rate_type",     limit: 255
  end

  add_index "pricing_setups", ["organization_id"], name: "index_pricing_setups_on_organization_id", using: :btree

  create_table "procedures", force: :cascade do |t|
    t.integer  "appointment_id",   limit: 4
    t.integer  "visit_id",         limit: 4
    t.boolean  "completed",                                           default: false
    t.datetime "created_at",                                                          null: false
    t.datetime "updated_at",                                                          null: false
    t.integer  "line_item_id",     limit: 4
    t.integer  "r_quantity",       limit: 4
    t.integer  "service_id",       limit: 4
    t.integer  "t_quantity",       limit: 4
    t.decimal  "unit_factor_cost",           precision: 12, scale: 4
    t.boolean  "toasts_generated",                                    default: false
  end

  add_index "procedures", ["appointment_id"], name: "index_procedures_on_appointment_id", using: :btree
  add_index "procedures", ["line_item_id"], name: "index_procedures_on_line_item_id", using: :btree
  add_index "procedures", ["visit_id"], name: "index_procedures_on_visit_id", using: :btree

  create_table "project_roles", force: :cascade do |t|
    t.integer  "protocol_id",    limit: 4
    t.integer  "identity_id",    limit: 4
    t.string   "project_rights", limit: 255
    t.string   "role",           limit: 255
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.datetime "deleted_at"
    t.string   "role_other",     limit: 255
    t.boolean  "epic_access",                default: false
  end

  add_index "project_roles", ["identity_id"], name: "index_project_roles_on_identity_id", using: :btree
  add_index "project_roles", ["protocol_id"], name: "index_project_roles_on_protocol_id", using: :btree

  create_table "protocol_filters", force: :cascade do |t|
    t.integer  "identity_id",       limit: 4
    t.string   "search_name",       limit: 255
    t.boolean  "show_archived"
    t.string   "search_query",      limit: 255
    t.string   "with_organization", limit: 255
    t.string   "with_status",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "admin_filter",      limit: 255
    t.string   "with_owner",        limit: 255
  end

  create_table "protocols", force: :cascade do |t|
    t.string   "type",                                  limit: 255
    t.integer  "next_ssr_id",                           limit: 4
    t.string   "short_title",                           limit: 255
    t.text     "title",                                 limit: 65535
    t.string   "sponsor_name",                          limit: 255
    t.text     "brief_description",                     limit: 65535
    t.decimal  "indirect_cost_rate",                                  precision: 5, scale: 2
    t.string   "study_phase",                           limit: 255
    t.string   "udak_project_number",                   limit: 255
    t.string   "funding_rfa",                           limit: 255
    t.string   "funding_status",                        limit: 255
    t.string   "potential_funding_source",              limit: 255
    t.datetime "potential_funding_start_date"
    t.string   "funding_source",                        limit: 255
    t.datetime "funding_start_date"
    t.string   "federal_grant_serial_number",           limit: 255
    t.string   "federal_grant_title",                   limit: 255
    t.string   "federal_grant_code_id",                 limit: 255
    t.string   "federal_non_phs_sponsor",               limit: 255
    t.string   "federal_phs_sponsor",                   limit: 255
    t.datetime "created_at",                                                                                  null: false
    t.datetime "updated_at",                                                                                  null: false
    t.datetime "deleted_at"
    t.string   "potential_funding_source_other",        limit: 255
    t.string   "funding_source_other",                  limit: 255
    t.datetime "last_epic_push_time"
    t.string   "last_epic_push_status",                 limit: 255
    t.datetime "start_date"
    t.datetime "end_date"
    t.string   "billing_business_manager_static_email", limit: 255
    t.datetime "recruitment_start_date"
    t.datetime "recruitment_end_date"
    t.boolean  "selected_for_epic"
    t.boolean  "archived",                                                                    default: false
    t.integer  "study_type_question_group_id",          limit: 4
  end

  add_index "protocols", ["next_ssr_id"], name: "index_protocols_on_next_ssr_id", using: :btree

  create_table "question_groups", force: :cascade do |t|
    t.text     "text",                   limit: 65535
    t.text     "help_text",              limit: 65535
    t.string   "reference_identifier",   limit: 255
    t.string   "data_export_identifier", limit: 255
    t.string   "common_namespace",       limit: 255
    t.string   "common_identifier",      limit: 255
    t.string   "display_type",           limit: 255
    t.string   "custom_class",           limit: 255
    t.string   "custom_renderer",        limit: 255
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "api_id",                 limit: 255
  end

  add_index "question_groups", ["api_id"], name: "uq_question_groups_api_id", unique: true, using: :btree

  create_table "questionnaire_responses", force: :cascade do |t|
    t.integer  "submission_id", limit: 4
    t.integer  "item_id",       limit: 4
    t.text     "content",       limit: 65535
    t.boolean  "required",                    default: false
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  add_index "questionnaire_responses", ["item_id"], name: "index_questionnaire_responses_on_item_id", using: :btree
  add_index "questionnaire_responses", ["submission_id"], name: "index_questionnaire_responses_on_submission_id", using: :btree

  create_table "questionnaires", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "service_id", limit: 4
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "active",                 default: false
  end

  add_index "questionnaires", ["service_id"], name: "index_questionnaires_on_service_id", using: :btree

  create_table "questions", force: :cascade do |t|
    t.integer  "survey_section_id",      limit: 4
    t.integer  "question_group_id",      limit: 4
    t.text     "text",                   limit: 65535
    t.text     "short_text",             limit: 65535
    t.text     "help_text",              limit: 65535
    t.string   "pick",                   limit: 255
    t.string   "reference_identifier",   limit: 255
    t.string   "data_export_identifier", limit: 255
    t.string   "common_namespace",       limit: 255
    t.string   "common_identifier",      limit: 255
    t.integer  "display_order",          limit: 4
    t.string   "display_type",           limit: 255
    t.boolean  "is_mandatory"
    t.integer  "display_width",          limit: 4
    t.string   "custom_class",           limit: 255
    t.string   "custom_renderer",        limit: 255
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "correct_answer_id",      limit: 4
    t.string   "api_id",                 limit: 255
  end

  add_index "questions", ["api_id"], name: "uq_questions_api_id", unique: true, using: :btree
  add_index "questions", ["correct_answer_id"], name: "index_questions_on_correct_answer_id", using: :btree
  add_index "questions", ["question_group_id"], name: "index_questions_on_question_group_id", using: :btree
  add_index "questions", ["survey_section_id"], name: "index_questions_on_survey_section_id", using: :btree

  create_table "quick_questions", force: :cascade do |t|
    t.string   "to",         limit: 255
    t.string   "from",       limit: 255
    t.text     "body",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "reports", force: :cascade do |t|
    t.integer  "sub_service_request_id", limit: 4
    t.string   "xlsx_file_name",         limit: 255
    t.string   "xlsx_content_type",      limit: 255
    t.integer  "xlsx_file_size",         limit: 4
    t.datetime "xlsx_updated_at"
    t.string   "report_type",            limit: 255
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  create_table "research_types_info", force: :cascade do |t|
    t.integer  "protocol_id",              limit: 4
    t.boolean  "human_subjects"
    t.boolean  "vertebrate_animals"
    t.boolean  "investigational_products"
    t.boolean  "ip_patents"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.datetime "deleted_at"
  end

  add_index "research_types_info", ["protocol_id"], name: "index_research_types_info_on_protocol_id", using: :btree

  create_table "response_sets", force: :cascade do |t|
    t.integer  "user_id",                limit: 4
    t.integer  "survey_id",              limit: 4
    t.string   "access_code",            limit: 255
    t.datetime "started_at"
    t.datetime "completed_at"
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.string   "api_id",                 limit: 255
    t.integer  "sub_service_request_id", limit: 4
  end

  add_index "response_sets", ["access_code"], name: "response_sets_ac_idx", unique: true, using: :btree
  add_index "response_sets", ["api_id"], name: "uq_response_sets_api_id", unique: true, using: :btree
  add_index "response_sets", ["survey_id"], name: "index_response_sets_on_survey_id", using: :btree
  add_index "response_sets", ["user_id"], name: "index_response_sets_on_user_id", using: :btree

  create_table "responses", force: :cascade do |t|
    t.integer  "response_set_id",   limit: 4
    t.integer  "question_id",       limit: 4
    t.integer  "answer_id",         limit: 4
    t.datetime "datetime_value"
    t.integer  "integer_value",     limit: 4
    t.float    "float_value",       limit: 24
    t.string   "unit",              limit: 255
    t.text     "text_value",        limit: 65535
    t.string   "string_value",      limit: 255
    t.string   "response_other",    limit: 255
    t.string   "response_group",    limit: 255
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "survey_section_id", limit: 4
    t.string   "api_id",            limit: 255
  end

  add_index "responses", ["answer_id"], name: "index_responses_on_answer_id", using: :btree
  add_index "responses", ["api_id"], name: "uq_responses_api_id", unique: true, using: :btree
  add_index "responses", ["question_id"], name: "index_responses_on_question_id", using: :btree
  add_index "responses", ["response_set_id"], name: "index_responses_on_response_set_id", using: :btree
  add_index "responses", ["survey_section_id"], name: "index_responses_on_survey_section_id", using: :btree

  create_table "revenue_code_ranges", force: :cascade do |t|
    t.integer  "from",           limit: 4
    t.integer  "to",             limit: 4
    t.float    "percentage",     limit: 24
    t.integer  "applied_org_id", limit: 4
    t.string   "vendor",         limit: 255
    t.integer  "version",        limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "service_providers", force: :cascade do |t|
    t.integer  "identity_id",        limit: 4
    t.integer  "organization_id",    limit: 4
    t.integer  "service_id",         limit: 4
    t.boolean  "is_primary_contact"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "hold_emails"
    t.datetime "deleted_at"
  end

  add_index "service_providers", ["identity_id"], name: "index_service_providers_on_identity_id", using: :btree
  add_index "service_providers", ["organization_id"], name: "index_service_providers_on_organization_id", using: :btree
  add_index "service_providers", ["service_id"], name: "index_service_providers_on_service_id", using: :btree

  create_table "service_relations", force: :cascade do |t|
    t.integer  "service_id",            limit: 4
    t.integer  "related_service_id",    limit: 4
    t.boolean  "optional"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.datetime "deleted_at"
    t.boolean  "linked_quantity",                 default: false
    t.integer  "linked_quantity_total", limit: 4
  end

  add_index "service_relations", ["related_service_id"], name: "index_service_relations_on_related_service_id", using: :btree
  add_index "service_relations", ["service_id"], name: "index_service_relations_on_service_id", using: :btree

  create_table "service_requests", force: :cascade do |t|
    t.integer  "protocol_id",             limit: 4
    t.string   "status",                  limit: 255
    t.boolean  "approved"
    t.integer  "subject_count",           limit: 4
    t.datetime "consult_arranged_date"
    t.datetime "pppv_complete_date"
    t.datetime "pppv_in_process_date"
    t.datetime "submitted_at"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.datetime "deleted_at"
    t.date     "original_submitted_date"
  end

  add_index "service_requests", ["protocol_id"], name: "index_service_requests_on_protocol_id", using: :btree
  add_index "service_requests", ["status"], name: "index_service_requests_on_status", using: :btree

  create_table "services", force: :cascade do |t|
    t.string   "name",                  limit: 255
    t.string   "abbreviation",          limit: 255
    t.integer  "order",                 limit: 4
    t.text     "description",           limit: 65535
    t.boolean  "is_available",                                                 default: true
    t.decimal  "service_center_cost",                 precision: 12, scale: 4
    t.string   "cpt_code",              limit: 255
    t.string   "charge_code",           limit: 255
    t.string   "revenue_code",          limit: 255
    t.integer  "organization_id",       limit: 4
    t.datetime "created_at",                                                                   null: false
    t.datetime "updated_at",                                                                   null: false
    t.datetime "deleted_at"
    t.boolean  "send_to_epic",                                                 default: false
    t.integer  "revenue_code_range_id", limit: 4
    t.boolean  "one_time_fee",                                                 default: false
    t.integer  "line_items_count",      limit: 4,                              default: 0
    t.text     "components",            limit: 65535
    t.string   "eap_id",                limit: 255
  end

  add_index "services", ["is_available"], name: "index_services_on_is_available", using: :btree
  add_index "services", ["one_time_fee"], name: "index_services_on_one_time_fee", using: :btree
  add_index "services", ["organization_id"], name: "index_services_on_organization_id", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255,   null: false
    t.text     "data",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "study_type_answers", force: :cascade do |t|
    t.integer  "protocol_id",            limit: 4
    t.integer  "study_type_question_id", limit: 4
    t.boolean  "answer"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  create_table "study_type_question_groups", force: :cascade do |t|
    t.boolean  "active",     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "study_type_questions", force: :cascade do |t|
    t.integer  "order",                        limit: 4
    t.string   "question",                     limit: 255
    t.string   "friendly_id",                  limit: 255
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "study_type_question_group_id", limit: 4
  end

  create_table "study_types", force: :cascade do |t|
    t.integer  "protocol_id", limit: 4
    t.string   "name",        limit: 255
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.datetime "deleted_at"
  end

  add_index "study_types", ["protocol_id"], name: "index_study_types_on_protocol_id", using: :btree

  create_table "sub_service_requests", force: :cascade do |t|
    t.integer  "service_request_id",         limit: 4
    t.integer  "organization_id",            limit: 4
    t.integer  "owner_id",                   limit: 4
    t.string   "ssr_id",                     limit: 255
    t.datetime "status_date"
    t.string   "status",                     limit: 255
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.datetime "deleted_at"
    t.datetime "consult_arranged_date"
    t.datetime "requester_contacted_date"
    t.boolean  "nursing_nutrition_approved",               default: false
    t.boolean  "lab_approved",                             default: false
    t.boolean  "imaging_approved",                         default: false
    t.boolean  "committee_approved",                       default: false
    t.boolean  "in_work_fulfillment",                      default: false
    t.string   "routing",                    limit: 255
    t.text     "org_tree_display",           limit: 65535
    t.integer  "service_requester_id",       limit: 4
    t.datetime "submitted_at"
  end

  add_index "sub_service_requests", ["organization_id"], name: "index_sub_service_requests_on_organization_id", using: :btree
  add_index "sub_service_requests", ["owner_id"], name: "index_sub_service_requests_on_owner_id", using: :btree
  add_index "sub_service_requests", ["service_request_id"], name: "index_sub_service_requests_on_service_request_id", using: :btree
  add_index "sub_service_requests", ["service_requester_id"], name: "index_sub_service_requests_on_service_requester_id", using: :btree
  add_index "sub_service_requests", ["ssr_id"], name: "index_sub_service_requests_on_ssr_id", using: :btree
  add_index "sub_service_requests", ["status"], name: "index_sub_service_requests_on_status", using: :btree

  create_table "subjects", force: :cascade do |t|
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "arm_id",              limit: 4
    t.string   "name",                limit: 255
    t.string   "mrn",                 limit: 255
    t.string   "external_subject_id", limit: 255
    t.date     "dob"
    t.string   "gender",              limit: 255
    t.string   "ethnicity",           limit: 255
    t.string   "status",              limit: 255
    t.boolean  "arm_edited"
  end

  add_index "subjects", ["arm_id"], name: "index_subjects_on_arm_id", using: :btree

  create_table "submission_emails", force: :cascade do |t|
    t.integer  "organization_id", limit: 4
    t.string   "email",           limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.datetime "deleted_at"
  end

  add_index "submission_emails", ["organization_id"], name: "index_submission_emails_on_organization_id", using: :btree

  create_table "submissions", force: :cascade do |t|
    t.integer  "service_id",       limit: 4
    t.integer  "identity_id",      limit: 4
    t.integer  "questionnaire_id", limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "submissions", ["identity_id"], name: "index_submissions_on_identity_id", using: :btree
  add_index "submissions", ["questionnaire_id"], name: "index_submissions_on_questionnaire_id", using: :btree
  add_index "submissions", ["service_id"], name: "index_submissions_on_service_id", using: :btree

  create_table "subsidies", force: :cascade do |t|
    t.datetime "created_at",                                             null: false
    t.datetime "updated_at",                                             null: false
    t.datetime "deleted_at"
    t.boolean  "overridden"
    t.integer  "sub_service_request_id", limit: 4
    t.integer  "total_at_approval",      limit: 4
    t.string   "status",                 limit: 255, default: "Pending"
    t.integer  "approved_by",            limit: 4
    t.datetime "approved_at"
    t.float    "percent_subsidy",        limit: 24,  default: 0.0
  end

  add_index "subsidies", ["sub_service_request_id"], name: "index_subsidies_on_sub_service_request_id", using: :btree

  create_table "subsidy_maps", force: :cascade do |t|
    t.integer  "organization_id",    limit: 4
    t.decimal  "max_dollar_cap",                   precision: 12, scale: 4, default: 0.0
    t.decimal  "max_percentage",                   precision: 5,  scale: 2, default: 0.0
    t.datetime "created_at",                                                              null: false
    t.datetime "updated_at",                                                              null: false
    t.datetime "deleted_at"
    t.float    "default_percentage", limit: 24,                             default: 0.0
    t.text     "instructions",       limit: 65535
  end

  add_index "subsidy_maps", ["organization_id"], name: "index_subsidy_maps_on_organization_id", using: :btree

  create_table "super_users", force: :cascade do |t|
    t.integer  "identity_id",     limit: 4
    t.integer  "organization_id", limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.datetime "deleted_at"
  end

  add_index "super_users", ["identity_id"], name: "index_super_users_on_identity_id", using: :btree
  add_index "super_users", ["organization_id"], name: "index_super_users_on_organization_id", using: :btree

  create_table "survey_sections", force: :cascade do |t|
    t.integer  "survey_id",              limit: 4
    t.string   "title",                  limit: 255
    t.text     "description",            limit: 65535
    t.string   "reference_identifier",   limit: 255
    t.string   "data_export_identifier", limit: 255
    t.string   "common_namespace",       limit: 255
    t.string   "common_identifier",      limit: 255
    t.integer  "display_order",          limit: 4
    t.string   "custom_class",           limit: 255
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  add_index "survey_sections", ["survey_id"], name: "index_survey_sections_on_survey_id", using: :btree

  create_table "survey_translations", force: :cascade do |t|
    t.integer  "survey_id",   limit: 4
    t.string   "locale",      limit: 255
    t.text     "translation", limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "survey_translations", ["survey_id"], name: "index_survey_translations_on_survey_id", using: :btree

  create_table "surveys", force: :cascade do |t|
    t.string   "title",                  limit: 255
    t.text     "description",            limit: 65535
    t.string   "access_code",            limit: 255
    t.string   "reference_identifier",   limit: 255
    t.string   "data_export_identifier", limit: 255
    t.string   "common_namespace",       limit: 255
    t.string   "common_identifier",      limit: 255
    t.datetime "active_at"
    t.datetime "inactive_at"
    t.string   "css_url",                limit: 255
    t.string   "custom_class",           limit: 255
    t.datetime "created_at",                                       null: false
    t.datetime "updated_at",                                       null: false
    t.integer  "display_order",          limit: 4
    t.string   "api_id",                 limit: 255
    t.integer  "survey_version",         limit: 4,     default: 0
  end

  add_index "surveys", ["access_code", "survey_version"], name: "surveys_access_code_version_idx", unique: true, using: :btree
  add_index "surveys", ["api_id"], name: "uq_surveys_api_id", unique: true, using: :btree

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id",        limit: 4
    t.integer  "taggable_id",   limit: 4
    t.string   "taggable_type", limit: 255
    t.integer  "tagger_id",     limit: 4
    t.string   "tagger_type",   limit: 255
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true, using: :btree
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context", using: :btree
  add_index "taggings", ["tagger_id"], name: "index_taggings_on_tagger_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string  "name",           limit: 255
    t.integer "taggings_count", limit: 4,   default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true, using: :btree

  create_table "toast_messages", force: :cascade do |t|
    t.integer  "from",             limit: 4
    t.integer  "to",               limit: 4
    t.string   "sending_class",    limit: 255
    t.integer  "sending_class_id", limit: 4
    t.string   "message",          limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "toast_messages", ["sending_class_id"], name: "index_toast_messages_on_sending_class_id", using: :btree

  create_table "tokens", force: :cascade do |t|
    t.integer  "service_request_id", limit: 4
    t.integer  "identity_id",        limit: 4
    t.string   "token",              limit: 255
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.datetime "deleted_at"
  end

  add_index "tokens", ["identity_id"], name: "index_tokens_on_identity_id", using: :btree
  add_index "tokens", ["service_request_id"], name: "index_tokens_on_service_request_id", using: :btree

  create_table "validation_conditions", force: :cascade do |t|
    t.integer  "validation_id",  limit: 4
    t.string   "rule_key",       limit: 255
    t.string   "operator",       limit: 255
    t.integer  "question_id",    limit: 4
    t.integer  "answer_id",      limit: 4
    t.datetime "datetime_value"
    t.integer  "integer_value",  limit: 4
    t.float    "float_value",    limit: 24
    t.string   "unit",           limit: 255
    t.text     "text_value",     limit: 65535
    t.string   "string_value",   limit: 255
    t.string   "response_other", limit: 255
    t.string   "regexp",         limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "validation_conditions", ["answer_id"], name: "index_validation_conditions_on_answer_id", using: :btree
  add_index "validation_conditions", ["question_id"], name: "index_validation_conditions_on_question_id", using: :btree
  add_index "validation_conditions", ["validation_id"], name: "index_validation_conditions_on_validation_id", using: :btree

  create_table "validations", force: :cascade do |t|
    t.integer  "answer_id",  limit: 4
    t.string   "rule",       limit: 255
    t.string   "message",    limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "validations", ["answer_id"], name: "index_validations_on_answer_id", using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  limit: 255,   null: false
    t.integer  "item_id",    limit: 4,     null: false
    t.string   "event",      limit: 255,   null: false
    t.string   "whodunnit",  limit: 255
    t.text     "object",     limit: 65535
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "vertebrate_animals_info", force: :cascade do |t|
    t.integer  "protocol_id",           limit: 4
    t.string   "iacuc_number",          limit: 255
    t.string   "name_of_iacuc",         limit: 255
    t.datetime "iacuc_approval_date"
    t.datetime "iacuc_expiration_date"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.datetime "deleted_at"
  end

  add_index "vertebrate_animals_info", ["protocol_id"], name: "index_vertebrate_animals_info_on_protocol_id", using: :btree

  create_table "visit_groups", force: :cascade do |t|
    t.string   "name",          limit: 255
    t.integer  "arm_id",        limit: 4
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "position",      limit: 4
    t.integer  "day",           limit: 4
    t.integer  "window_before", limit: 4,   default: 0
    t.integer  "window_after",  limit: 4,   default: 0
  end

  add_index "visit_groups", ["arm_id"], name: "index_visit_groups_on_arm_id", using: :btree

  create_table "visits", force: :cascade do |t|
    t.integer  "quantity",              limit: 4,   default: 0
    t.string   "billing",               limit: 255
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.datetime "deleted_at"
    t.integer  "research_billing_qty",  limit: 4,   default: 0
    t.integer  "insurance_billing_qty", limit: 4,   default: 0
    t.integer  "effort_billing_qty",    limit: 4,   default: 0
    t.integer  "line_items_visit_id",   limit: 4
    t.integer  "visit_group_id",        limit: 4
  end

  add_index "visits", ["line_items_visit_id"], name: "index_visits_on_line_items_visit_id", using: :btree
  add_index "visits", ["research_billing_qty"], name: "index_visits_on_research_billing_qty", using: :btree
  add_index "visits", ["visit_group_id"], name: "index_visits_on_visit_group_id", using: :btree

  add_foreign_key "item_options", "items"
  add_foreign_key "items", "questionnaires"
  add_foreign_key "questionnaire_responses", "items"
  add_foreign_key "questionnaire_responses", "submissions"
  add_foreign_key "questionnaires", "services"
  add_foreign_key "submissions", "identities"
  add_foreign_key "submissions", "questionnaires"
  add_foreign_key "submissions", "services"
end
