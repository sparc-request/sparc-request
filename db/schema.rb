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

ActiveRecord::Schema.define(version: 20170707153553) do

  create_table "admin_rates", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer "line_item_id"
    t.integer "admin_cost"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "affiliations", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "protocol_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["protocol_id"], name: "index_affiliations_on_protocol_id"
  end

  create_table "alerts", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.string "alert_type"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "approvals", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "service_request_id"
    t.integer "identity_id"
    t.datetime "approval_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "approval_type", default: "Resource Approval"
    t.integer "sub_service_request_id"
    t.index ["identity_id"], name: "index_approvals_on_identity_id"
    t.index ["service_request_id"], name: "index_approvals_on_service_request_id"
    t.index ["sub_service_request_id"], name: "index_approvals_on_sub_service_request_id"
  end

  create_table "arms", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "name"
    t.integer "visit_count", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "subject_count", default: 1
    t.integer "protocol_id"
    t.boolean "new_with_draft", default: false
    t.integer "minimum_visit_count", default: 0
    t.integer "minimum_subject_count", default: 0
    t.index ["protocol_id"], name: "index_arms_on_protocol_id"
  end

  create_table "associated_surveys", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "surveyable_id"
    t.string "surveyable_type"
    t.integer "survey_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["survey_id"], name: "index_associated_surveys_on_survey_id"
    t.index ["surveyable_id"], name: "index_associated_surveys_on_surveyable_id"
  end

  create_table "audits", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.text "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.datetime "created_at"
    t.string "request_uuid"
    t.index ["associated_id", "associated_type"], name: "associated_index"
    t.index ["auditable_id", "auditable_type"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "available_statuses", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "organization_id"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_available_statuses_on_organization_id"
  end

  create_table "catalog_managers", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "identity_id"
    t.integer "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.boolean "edit_historic_data"
    t.index ["identity_id"], name: "index_catalog_managers_on_identity_id"
    t.index ["organization_id"], name: "index_catalog_managers_on_organization_id"
  end

  create_table "charges", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "service_request_id"
    t.integer "service_id"
    t.decimal "charge_amount", precision: 12, scale: 4
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["service_id"], name: "index_charges_on_service_id"
    t.index ["service_request_id"], name: "index_charges_on_service_request_id"
  end

  create_table "clinical_providers", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "identity_id"
    t.integer "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["identity_id"], name: "index_clinical_providers_on_identity_id"
    t.index ["organization_id"], name: "index_clinical_providers_on_organization_id"
  end

  create_table "cover_letters", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.text "content"
    t.integer "sub_service_request_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sub_service_request_id"], name: "index_cover_letters_on_sub_service_request_id"
  end

  create_table "delayed_jobs", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", limit: 4294967295, null: false
    t.text "last_error", limit: 4294967295
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "documents", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.datetime "deleted_at"
    t.string "doc_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "document_file_name"
    t.string "document_content_type"
    t.integer "document_file_size"
    t.datetime "document_updated_at"
    t.string "doc_type_other"
    t.integer "protocol_id"
    t.index ["protocol_id"], name: "index_documents_on_protocol_id"
  end

  create_table "documents_sub_service_requests", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer "document_id"
    t.integer "sub_service_request_id"
  end

  create_table "editable_statuses", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "organization_id"
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id"], name: "index_editable_statuses_on_organization_id"
  end

  create_table "epic_queue_records", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer "protocol_id"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "origin"
    t.integer "identity_id"
  end

  create_table "epic_queues", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer "protocol_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "identity_id"
    t.boolean "attempted_push", default: false
  end

  create_table "epic_rights", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "project_role_id"
    t.string "right"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "excluded_funding_sources", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "subsidy_map_id"
    t.string "funding_source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["subsidy_map_id"], name: "index_excluded_funding_sources_on_subsidy_map_id"
  end

  create_table "feedbacks", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.text "message"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fulfillments", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "line_item_id"
    t.string "timeframe"
    t.string "time"
    t.datetime "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "unit_type"
    t.string "quantity_type"
    t.integer "quantity"
    t.integer "unit_quantity"
    t.index ["line_item_id"], name: "index_fulfillments_on_line_item_id"
  end

  create_table "human_subjects_info", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "protocol_id"
    t.string "hr_number"
    t.string "pro_number"
    t.string "irb_of_record"
    t.string "submission_type"
    t.datetime "irb_approval_date"
    t.datetime "irb_expiration_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.boolean "approval_pending"
    t.string "nct_number"
    t.index ["protocol_id"], name: "index_human_subjects_info_on_protocol_id"
  end

  create_table "identities", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "ldap_uid"
    t.string "email"
    t.string "last_name"
    t.string "first_name"
    t.string "era_commons_name"
    t.string "credentials"
    t.string "subspecialty"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.boolean "catalog_overlord"
    t.string "credentials_other"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.text "reason"
    t.string "company"
    t.boolean "approved", default: false, null: false
    t.string "time_zone", default: "Eastern Time (US & Canada)"
    t.integer "professional_organization_id"
    t.index ["approved"], name: "index_identities_on_approved"
    t.index ["email"], name: "index_identities_on_email"
    t.index ["last_name"], name: "index_identities_on_last_name"
    t.index ["ldap_uid"], name: "index_identities_on_ldap_uid", unique: true
    t.index ["reset_password_token"], name: "index_identities_on_reset_password_token", unique: true
  end

  create_table "impact_areas", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "protocol_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "other_text"
    t.index ["protocol_id"], name: "index_impact_areas_on_protocol_id"
  end

  create_table "investigational_products_info", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "protocol_id"
    t.string "ind_number"
    t.boolean "ind_on_hold"
    t.string "inv_device_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "exemption_type", default: ""
    t.index ["protocol_id"], name: "index_investigational_products_info_on_protocol_id"
  end

  create_table "ip_patents_info", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "protocol_id"
    t.string "patent_number"
    t.text "inventors"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["protocol_id"], name: "index_ip_patents_info_on_protocol_id"
  end

  create_table "item_options", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.string "content"
    t.boolean "validate_content"
    t.integer "item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_item_options_on_item_id"
  end

  create_table "items", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.text "content"
    t.string "item_type"
    t.text "description"
    t.boolean "required"
    t.integer "questionnaire_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["questionnaire_id"], name: "index_items_on_questionnaire_id"
  end

  create_table "line_items", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "service_request_id"
    t.integer "sub_service_request_id"
    t.integer "service_id"
    t.boolean "optional", default: true
    t.integer "quantity"
    t.datetime "complete_date"
    t.datetime "in_process_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.integer "units_per_quantity", default: 1
    t.index ["service_id"], name: "index_line_items_on_service_id"
    t.index ["service_request_id"], name: "index_line_items_on_service_request_id"
    t.index ["sub_service_request_id"], name: "index_line_items_on_sub_service_request_id"
  end

  create_table "line_items_visits", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "arm_id"
    t.integer "line_item_id"
    t.integer "subject_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["arm_id"], name: "index_line_items_visits_on_arm_id"
    t.index ["line_item_id"], name: "index_line_items_visits_on_line_item_id"
  end

  create_table "lookups", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "new_id"
    t.string "old_id"
  end

  create_table "messages", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "notification_id"
    t.integer "to"
    t.integer "from"
    t.string "email"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notification_id"], name: "index_messages_on_notification_id"
  end

  create_table "notes", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "identity_id"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "notable_id"
    t.string "notable_type"
    t.index ["identity_id"], name: "index_notes_on_identity_id"
    t.index ["identity_id"], name: "index_notes_on_user_id"
    t.index ["notable_id", "notable_type"], name: "index_notes_on_notable_id_and_notable_type"
  end

  create_table "notifications", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "sub_service_request_id"
    t.integer "originator_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "subject"
    t.integer "other_user_id"
    t.boolean "read_by_originator"
    t.boolean "read_by_other_user"
    t.index ["originator_id"], name: "index_notifications_on_originator_id"
    t.index ["sub_service_request_id"], name: "index_notifications_on_sub_service_request_id"
  end

  create_table "options", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer "question_id"
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_options_on_question_id"
  end

  create_table "organizations", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "type"
    t.string "name"
    t.integer "order"
    t.string "css_class", default: ""
    t.text "description"
    t.integer "parent_id"
    t.string "abbreviation"
    t.text "ack_language"
    t.boolean "process_ssrs", default: false
    t.boolean "is_available", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["is_available"], name: "index_organizations_on_is_available"
    t.index ["parent_id"], name: "index_organizations_on_parent_id"
  end

  create_table "past_statuses", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "sub_service_request_id"
    t.string "status"
    t.datetime "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.integer "changed_by_id"
    t.index ["changed_by_id"], name: "index_past_statuses_on_changed_by_id"
    t.index ["sub_service_request_id"], name: "index_past_statuses_on_sub_service_request_id"
  end

  create_table "past_subsidies", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer "sub_service_request_id"
    t.integer "total_at_approval"
    t.integer "approved_by"
    t.datetime "approved_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float "percent_subsidy", limit: 24, default: 0.0
    t.index ["approved_by"], name: "index_past_subsidies_on_approved_by"
    t.index ["sub_service_request_id"], name: "index_past_subsidies_on_sub_service_request_id"
  end

  create_table "payment_uploads", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "payment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "file_file_name"
    t.string "file_content_type"
    t.integer "file_file_size"
    t.datetime "file_updated_at"
    t.index ["payment_id"], name: "index_payment_uploads_on_payment_id"
  end

  create_table "payments", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "sub_service_request_id"
    t.date "date_submitted"
    t.decimal "amount_invoiced", precision: 12, scale: 4
    t.decimal "amount_received", precision: 12, scale: 4
    t.date "date_received"
    t.string "payment_method"
    t.text "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "percent_subsidy", limit: 24
    t.index ["sub_service_request_id"], name: "index_payments_on_sub_service_request_id"
  end

  create_table "pricing_maps", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "service_id"
    t.string "unit_type"
    t.decimal "unit_factor", precision: 5, scale: 2
    t.decimal "percent_of_fee", precision: 5, scale: 2
    t.decimal "full_rate", precision: 12, scale: 4
    t.boolean "exclude_from_indirect_cost"
    t.integer "unit_minimum"
    t.decimal "federal_rate", precision: 12, scale: 4
    t.decimal "corporate_rate", precision: 12, scale: 4
    t.date "effective_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.date "display_date"
    t.decimal "other_rate", precision: 12, scale: 4
    t.decimal "member_rate", precision: 12, scale: 4
    t.integer "units_per_qty_max", default: 10000
    t.string "quantity_type"
    t.string "otf_unit_type", default: "N/A"
    t.integer "quantity_minimum", default: 1
    t.index ["service_id"], name: "index_pricing_maps_on_service_id"
  end

  create_table "pricing_setups", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "organization_id"
    t.date "display_date"
    t.date "effective_date"
    t.boolean "charge_master"
    t.decimal "federal", precision: 5, scale: 2
    t.decimal "corporate", precision: 5, scale: 2
    t.decimal "other", precision: 5, scale: 2
    t.decimal "member", precision: 5, scale: 2
    t.string "college_rate_type"
    t.string "federal_rate_type"
    t.string "industry_rate_type"
    t.string "investigator_rate_type"
    t.string "internal_rate_type"
    t.string "foundation_rate_type"
    t.datetime "deleted_at"
    t.string "unfunded_rate_type"
    t.index ["organization_id"], name: "index_pricing_setups_on_organization_id"
  end

  create_table "professional_organizations", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.text "name"
    t.string "org_type"
    t.integer "parent_id"
  end

  create_table "project_roles", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "protocol_id"
    t.integer "identity_id"
    t.string "project_rights"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "role_other"
    t.boolean "epic_access", default: false
    t.index ["identity_id"], name: "index_project_roles_on_identity_id"
    t.index ["protocol_id"], name: "index_project_roles_on_protocol_id"
  end

  create_table "protocol_filters", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer "identity_id"
    t.string "search_name"
    t.boolean "show_archived"
    t.string "search_query"
    t.string "with_organization"
    t.string "with_status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "admin_filter"
    t.string "with_owner"
  end

  create_table "protocols", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "type"
    t.integer "next_ssr_id"
    t.string "short_title"
    t.text "title"
    t.string "sponsor_name"
    t.text "brief_description"
    t.decimal "indirect_cost_rate", precision: 5, scale: 2
    t.string "study_phase"
    t.string "udak_project_number"
    t.string "funding_rfa"
    t.string "funding_status"
    t.string "potential_funding_source"
    t.datetime "potential_funding_start_date"
    t.string "funding_source"
    t.datetime "funding_start_date"
    t.string "federal_grant_serial_number"
    t.string "federal_grant_title"
    t.string "federal_grant_code_id"
    t.string "federal_non_phs_sponsor"
    t.string "federal_phs_sponsor"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "potential_funding_source_other"
    t.string "funding_source_other"
    t.datetime "last_epic_push_time"
    t.string "last_epic_push_status"
    t.datetime "start_date"
    t.datetime "end_date"
    t.string "billing_business_manager_static_email"
    t.datetime "recruitment_start_date"
    t.datetime "recruitment_end_date"
    t.boolean "selected_for_epic"
    t.boolean "archived", default: false
    t.integer "study_type_question_group_id"
    t.integer "research_master_id"
    t.integer "sub_service_requests_count", default: 0
    t.boolean "rmid_validated", default: false
    t.index ["next_ssr_id"], name: "index_protocols_on_next_ssr_id"
  end

  create_table "protocols_study_phases", id: false, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer "protocol_id", null: false
    t.integer "study_phase_id", null: false
    t.index ["protocol_id", "study_phase_id"], name: "index_protocols_study_phases_on_protocol_id_and_study_phase_id"
    t.index ["study_phase_id", "protocol_id"], name: "index_protocols_study_phases_on_study_phase_id_and_protocol_id"
  end

  create_table "question_responses", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer "question_id"
    t.integer "response_id"
    t.text "content"
    t.boolean "required", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_question_responses_on_question_id"
    t.index ["response_id"], name: "index_question_responses_on_response_id"
  end

  create_table "questionnaire_responses", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer "submission_id"
    t.integer "item_id"
    t.text "content"
    t.boolean "required", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_questionnaire_responses_on_item_id"
    t.index ["submission_id"], name: "index_questionnaire_responses_on_submission_id"
  end

  create_table "questionnaires", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.string "name"
    t.integer "service_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: false
    t.index ["service_id"], name: "index_questionnaires_on_service_id"
  end

  create_table "questions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer "section_id"
    t.boolean "is_dependent", null: false
    t.text "content", null: false
    t.string "question_type", null: false
    t.text "description"
    t.boolean "required", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "depender_id"
    t.index ["depender_id"], name: "index_questions_on_depender_id"
    t.index ["section_id"], name: "index_questions_on_section_id"
  end

  create_table "quick_questions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "to"
    t.string "from"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reports", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "sub_service_request_id"
    t.string "xlsx_file_name"
    t.string "xlsx_content_type"
    t.integer "xlsx_file_size"
    t.datetime "xlsx_updated_at"
    t.string "report_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "research_types_info", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "protocol_id"
    t.boolean "human_subjects"
    t.boolean "vertebrate_animals"
    t.boolean "investigational_products"
    t.boolean "ip_patents"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["protocol_id"], name: "index_research_types_info_on_protocol_id"
  end

  create_table "responses", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer "survey_id"
    t.integer "identity_id"
    t.integer "sub_service_request_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["identity_id"], name: "index_responses_on_identity_id"
    t.index ["sub_service_request_id"], name: "index_responses_on_sub_service_request_id"
    t.index ["survey_id"], name: "index_responses_on_survey_id"
  end

  create_table "revenue_code_ranges", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer "from"
    t.integer "to"
    t.float "percentage", limit: 24
    t.integer "applied_org_id"
    t.string "vendor"
    t.integer "version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sections", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer "survey_id"
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["survey_id"], name: "index_sections_on_survey_id"
  end

  create_table "service_providers", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "identity_id"
    t.integer "organization_id"
    t.integer "service_id"
    t.boolean "is_primary_contact"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "hold_emails"
    t.datetime "deleted_at"
    t.index ["identity_id"], name: "index_service_providers_on_identity_id"
    t.index ["organization_id"], name: "index_service_providers_on_organization_id"
    t.index ["service_id"], name: "index_service_providers_on_service_id"
  end

  create_table "service_relations", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "service_id"
    t.integer "related_service_id"
    t.boolean "optional"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.boolean "linked_quantity", default: false
    t.integer "linked_quantity_total"
    t.index ["related_service_id"], name: "index_service_relations_on_related_service_id"
    t.index ["service_id"], name: "index_service_relations_on_service_id"
  end

  create_table "service_requests", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "protocol_id"
    t.string "status"
    t.boolean "approved"
    t.datetime "submitted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.date "original_submitted_date"
    t.index ["protocol_id"], name: "index_service_requests_on_protocol_id"
    t.index ["status"], name: "index_service_requests_on_status"
  end

  create_table "services", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name"
    t.string "abbreviation"
    t.integer "order"
    t.text "description"
    t.boolean "is_available", default: true
    t.decimal "service_center_cost", precision: 12, scale: 4
    t.string "cpt_code"
    t.string "charge_code"
    t.string "revenue_code"
    t.integer "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.boolean "send_to_epic", default: false
    t.integer "revenue_code_range_id"
    t.boolean "one_time_fee", default: false
    t.integer "line_items_count", default: 0
    t.text "components"
    t.string "eap_id"
    t.index ["is_available"], name: "index_services_on_is_available"
    t.index ["one_time_fee"], name: "index_services_on_one_time_fee"
    t.index ["organization_id"], name: "index_services_on_organization_id"
  end

  create_table "sessions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id"
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "study_phases", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer "order"
    t.string "phase"
    t.integer "version", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "study_type_answers", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer "protocol_id"
    t.integer "study_type_question_id"
    t.boolean "answer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "study_type_question_groups", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer "version"
    t.boolean "active", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "study_type_questions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer "order"
    t.text "question"
    t.string "friendly_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "study_type_question_group_id"
  end

  create_table "study_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "protocol_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["protocol_id"], name: "index_study_types_on_protocol_id"
  end

  create_table "sub_service_requests", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "service_request_id"
    t.integer "organization_id"
    t.integer "owner_id"
    t.string "ssr_id"
    t.datetime "status_date"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.datetime "consult_arranged_date"
    t.datetime "requester_contacted_date"
    t.boolean "nursing_nutrition_approved", default: false
    t.boolean "lab_approved", default: false
    t.boolean "imaging_approved", default: false
    t.boolean "committee_approved", default: false
    t.boolean "in_work_fulfillment", default: false
    t.string "routing"
    t.text "org_tree_display"
    t.integer "service_requester_id"
    t.datetime "submitted_at"
    t.integer "protocol_id"
    t.index ["organization_id"], name: "index_sub_service_requests_on_organization_id"
    t.index ["owner_id"], name: "index_sub_service_requests_on_owner_id"
    t.index ["protocol_id"], name: "index_sub_service_requests_on_protocol_id"
    t.index ["service_request_id"], name: "index_sub_service_requests_on_service_request_id"
    t.index ["service_requester_id"], name: "index_sub_service_requests_on_service_requester_id"
    t.index ["ssr_id"], name: "index_sub_service_requests_on_ssr_id"
    t.index ["status"], name: "index_sub_service_requests_on_status"
  end

  create_table "submission_emails", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "organization_id"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["organization_id"], name: "index_submission_emails_on_organization_id"
  end

  create_table "submissions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.integer "service_id"
    t.integer "identity_id"
    t.integer "questionnaire_id"
    t.integer "protocol_id"
    t.integer "line_item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["identity_id"], name: "index_submissions_on_identity_id"
    t.index ["line_item_id"], name: "index_submissions_on_line_item_id"
    t.index ["protocol_id"], name: "index_submissions_on_protocol_id"
    t.index ["questionnaire_id"], name: "index_submissions_on_questionnaire_id"
    t.index ["service_id"], name: "index_submissions_on_service_id"
  end

  create_table "subsidies", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.boolean "overridden"
    t.integer "sub_service_request_id"
    t.integer "total_at_approval"
    t.string "status", default: "Pending"
    t.integer "approved_by"
    t.datetime "approved_at"
    t.float "percent_subsidy", limit: 24, default: 0.0
    t.index ["sub_service_request_id"], name: "index_subsidies_on_sub_service_request_id"
  end

  create_table "subsidy_maps", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "organization_id"
    t.decimal "max_dollar_cap", precision: 12, scale: 4, default: "0.0"
    t.decimal "max_percentage", precision: 5, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.float "default_percentage", limit: 24, default: 0.0
    t.text "instructions"
    t.index ["organization_id"], name: "index_subsidy_maps_on_organization_id"
  end

  create_table "super_users", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "identity_id"
    t.integer "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["identity_id"], name: "index_super_users_on_identity_id"
    t.index ["organization_id"], name: "index_super_users_on_organization_id"
  end

  create_table "surveys", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin" do |t|
    t.string "title", null: false
    t.text "description"
    t.string "access_code", null: false
    t.integer "display_order", null: false
    t.integer "version", null: false
    t.boolean "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "taggings", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer "tag_id"
    t.integer "taggable_id"
    t.string "taggable_type"
    t.integer "tagger_id"
    t.string "tagger_type"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "name", collation: "utf8_bin"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "toast_messages", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "from"
    t.integer "to"
    t.string "sending_class"
    t.integer "sending_class_id"
    t.string "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sending_class_id"], name: "index_toast_messages_on_sending_class_id"
  end

  create_table "tokens", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "service_request_id"
    t.integer "identity_id"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["identity_id"], name: "index_tokens_on_identity_id"
    t.index ["service_request_id"], name: "index_tokens_on_service_request_id"
  end

  create_table "versions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  create_table "vertebrate_animals_info", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "protocol_id"
    t.string "iacuc_number"
    t.string "name_of_iacuc"
    t.datetime "iacuc_approval_date"
    t.datetime "iacuc_expiration_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["protocol_id"], name: "index_vertebrate_animals_info_on_protocol_id"
  end

  create_table "visit_groups", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "name"
    t.integer "arm_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.integer "day"
    t.integer "window_before", default: 0
    t.integer "window_after", default: 0
    t.index ["arm_id"], name: "index_visit_groups_on_arm_id"
  end

  create_table "visits", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "quantity", default: 0
    t.string "billing"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.integer "research_billing_qty", default: 0
    t.integer "insurance_billing_qty", default: 0
    t.integer "effort_billing_qty", default: 0
    t.integer "line_items_visit_id"
    t.integer "visit_group_id"
    t.index ["line_items_visit_id"], name: "index_visits_on_line_items_visit_id"
    t.index ["research_billing_qty"], name: "index_visits_on_research_billing_qty"
    t.index ["visit_group_id"], name: "index_visits_on_visit_group_id"
  end

  add_foreign_key "editable_statuses", "organizations"
  add_foreign_key "item_options", "items"
  add_foreign_key "items", "questionnaires"
  add_foreign_key "options", "questions"
  add_foreign_key "question_responses", "questions"
  add_foreign_key "question_responses", "responses"
  add_foreign_key "questionnaire_responses", "items"
  add_foreign_key "questionnaire_responses", "submissions"
  add_foreign_key "questionnaires", "services"
  add_foreign_key "questions", "options", column: "depender_id"
  add_foreign_key "questions", "sections"
  add_foreign_key "responses", "identities"
  add_foreign_key "responses", "sub_service_requests"
  add_foreign_key "responses", "surveys"
  add_foreign_key "sections", "surveys"
  add_foreign_key "submissions", "identities"
  add_foreign_key "submissions", "line_items"
  add_foreign_key "submissions", "protocols"
  add_foreign_key "submissions", "questionnaires"
  add_foreign_key "submissions", "services"
end
