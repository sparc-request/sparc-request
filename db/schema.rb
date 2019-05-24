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

ActiveRecord::Schema.define(version: 2019_05_14_181151) do

  create_table "admin_rates", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "line_item_id"
    t.integer "admin_cost"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "affiliations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "protocol_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["protocol_id"], name: "index_affiliations_on_protocol_id"
  end

  create_table "alerts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "alert_type"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "approvals", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "service_request_id"
    t.bigint "identity_id"
    t.datetime "approval_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "approval_type", default: "Resource Approval"
    t.bigint "sub_service_request_id"
    t.index ["identity_id"], name: "index_approvals_on_identity_id"
    t.index ["service_request_id"], name: "index_approvals_on_service_request_id"
    t.index ["sub_service_request_id"], name: "index_approvals_on_sub_service_request_id"
  end

  create_table "arms", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.integer "visit_count", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "subject_count", default: 1
    t.bigint "protocol_id"
    t.boolean "new_with_draft", default: false
    t.integer "minimum_visit_count", default: 0
    t.integer "minimum_subject_count", default: 0
    t.index ["protocol_id"], name: "index_arms_on_protocol_id"
  end

  create_table "associated_surveys", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "associable_id"
    t.string "associable_type"
    t.bigint "survey_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["associable_id"], name: "index_associated_surveys_on_associable_id"
    t.index ["survey_id"], name: "index_associated_surveys_on_survey_id"
  end

  create_table "audits", options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.bigint "auditable_id"
    t.string "auditable_type"
    t.bigint "associated_id"
    t.string "associated_type"
    t.bigint "user_id"
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

  create_table "available_statuses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "organization_id"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "selected", default: false
    t.index ["organization_id"], name: "index_available_statuses_on_organization_id"
  end

  create_table "catalog_managers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "identity_id"
    t.bigint "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.boolean "edit_historic_data"
    t.index ["identity_id"], name: "index_catalog_managers_on_identity_id"
    t.index ["organization_id"], name: "index_catalog_managers_on_organization_id"
  end

  create_table "charges", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "service_request_id"
    t.bigint "service_id"
    t.decimal "charge_amount", precision: 12, scale: 4
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["service_id"], name: "index_charges_on_service_id"
    t.index ["service_request_id"], name: "index_charges_on_service_request_id"
  end

  create_table "clinical_providers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "identity_id"
    t.bigint "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["identity_id"], name: "index_clinical_providers_on_identity_id"
    t.index ["organization_id"], name: "index_clinical_providers_on_organization_id"
  end

  create_table "cover_letters", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.text "content"
    t.bigint "sub_service_request_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sub_service_request_id"], name: "index_cover_letters_on_sub_service_request_id"
  end

  create_table "delayed_jobs", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
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

  create_table "documents", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.datetime "deleted_at"
    t.string "doc_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "document_file_name"
    t.string "document_content_type"
    t.integer "document_file_size"
    t.datetime "document_updated_at"
    t.string "doc_type_other"
    t.bigint "protocol_id"
    t.index ["protocol_id"], name: "index_documents_on_protocol_id"
  end

  create_table "documents_sub_service_requests", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "document_id"
    t.bigint "sub_service_request_id"
  end

  create_table "editable_statuses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "organization_id"
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "selected", default: false
    t.index ["organization_id"], name: "index_editable_statuses_on_organization_id"
  end

  create_table "epic_queue_records", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "protocol_id"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "origin"
    t.bigint "identity_id"
  end

  create_table "epic_queues", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "protocol_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "identity_id"
    t.boolean "attempted_push", default: false
    t.boolean "user_change", default: false
  end

  create_table "epic_rights", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "project_role_id"
    t.string "right"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "excluded_funding_sources", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "subsidy_map_id"
    t.string "funding_source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["subsidy_map_id"], name: "index_excluded_funding_sources_on_subsidy_map_id"
  end

  create_table "feedbacks", id: :bigint, default: nil, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.text "message"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fulfillments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "line_item_id"
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

  create_table "human_subjects_info", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "protocol_id"
    t.string "pro_number"
    t.string "irb_of_record"
    t.string "submission_type"
    t.date "initial_irb_approval_date"
    t.date "irb_approval_date"
    t.date "irb_expiration_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.boolean "approval_pending"
    t.string "nct_number"
    t.index ["protocol_id"], name: "index_human_subjects_info_on_protocol_id"
  end

  create_table "identities", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
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
    t.boolean "approved"
    t.string "time_zone", default: "Eastern Time (US & Canada)"
    t.bigint "professional_organization_id"
    t.string "orcid", limit: 19
    t.index ["approved"], name: "index_identities_on_approved"
    t.index ["email"], name: "index_identities_on_email"
    t.index ["last_name"], name: "index_identities_on_last_name"
    t.index ["ldap_uid"], name: "index_identities_on_ldap_uid", unique: true
    t.index ["reset_password_token"], name: "index_identities_on_reset_password_token", unique: true
  end

  create_table "impact_areas", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "protocol_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "other_text"
    t.index ["protocol_id"], name: "index_impact_areas_on_protocol_id"
  end

  create_table "investigational_products_info", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "protocol_id"
    t.string "ind_number"
    t.boolean "ind_on_hold"
    t.string "inv_device_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "exemption_type", default: ""
    t.index ["protocol_id"], name: "index_investigational_products_info_on_protocol_id"
  end

  create_table "ip_patents_info", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "protocol_id"
    t.string "patent_number"
    t.text "inventors"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["protocol_id"], name: "index_ip_patents_info_on_protocol_id"
  end

  create_table "line_items", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "service_request_id"
    t.bigint "sub_service_request_id"
    t.bigint "service_id"
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

  create_table "line_items_visits", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "arm_id"
    t.bigint "line_item_id"
    t.integer "subject_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["arm_id"], name: "index_line_items_visits_on_arm_id"
    t.index ["line_item_id"], name: "index_line_items_visits_on_line_item_id"
  end

  create_table "messages", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "notification_id"
    t.bigint "to"
    t.bigint "from"
    t.string "email"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from"], name: "index_messages_on_from"
    t.index ["notification_id"], name: "index_messages_on_notification_id"
    t.index ["to"], name: "index_messages_on_to"
  end

  create_table "notes", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "identity_id"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "notable_id"
    t.string "notable_type"
    t.index ["identity_id"], name: "index_notes_on_identity_id"
    t.index ["identity_id"], name: "index_notes_on_user_id"
    t.index ["notable_id", "notable_type"], name: "index_notes_on_notable_id_and_notable_type"
  end

  create_table "notifications", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "sub_service_request_id"
    t.bigint "originator_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "subject"
    t.bigint "other_user_id"
    t.boolean "read_by_originator"
    t.boolean "read_by_other_user"
    t.index ["originator_id"], name: "index_notifications_on_originator_id"
    t.index ["sub_service_request_id"], name: "index_notifications_on_sub_service_request_id"
  end

  create_table "options", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "question_id"
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_options_on_question_id"
  end

  create_table "organizations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "type"
    t.string "name"
    t.integer "order"
    t.string "css_class", default: ""
    t.text "description"
    t.bigint "parent_id"
    t.string "abbreviation"
    t.text "ack_language"
    t.boolean "process_ssrs", default: false
    t.boolean "is_available", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.boolean "use_default_statuses", default: true
    t.index ["is_available"], name: "index_organizations_on_is_available"
    t.index ["parent_id"], name: "index_organizations_on_parent_id"
  end

  create_table "past_statuses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "sub_service_request_id"
    t.string "status"
    t.datetime "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.bigint "changed_by_id"
    t.string "new_status"
    t.index ["changed_by_id"], name: "index_past_statuses_on_changed_by_id"
    t.index ["sub_service_request_id"], name: "index_past_statuses_on_sub_service_request_id"
  end

  create_table "past_subsidies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "sub_service_request_id"
    t.integer "total_at_approval"
    t.bigint "approved_by"
    t.datetime "approved_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float "percent_subsidy", default: 0.0
    t.index ["approved_by"], name: "index_past_subsidies_on_approved_by"
    t.index ["sub_service_request_id"], name: "index_past_subsidies_on_sub_service_request_id"
  end

  create_table "patient_registrars", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "identity_id"
    t.integer "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["identity_id"], name: "index_patient_registrars_on_identity_id"
    t.index ["organization_id"], name: "index_patient_registrars_on_organization_id"
  end

  create_table "payment_uploads", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "payment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "file_file_name"
    t.string "file_content_type"
    t.integer "file_file_size"
    t.datetime "file_updated_at"
    t.index ["payment_id"], name: "index_payment_uploads_on_payment_id"
  end

  create_table "payments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "sub_service_request_id"
    t.date "date_submitted"
    t.decimal "amount_invoiced", precision: 12, scale: 4
    t.decimal "amount_received", precision: 12, scale: 4
    t.date "date_received"
    t.string "payment_method"
    t.text "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "percent_subsidy"
    t.index ["sub_service_request_id"], name: "index_payments_on_sub_service_request_id"
  end

  create_table "permissible_values", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "key"
    t.string "value"
    t.string "concept_code"
    t.bigint "parent_id"
    t.integer "sort_order"
    t.string "category"
    t.boolean "default"
    t.boolean "reserved"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_available"
  end

  create_table "pricing_maps", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "service_id"
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

  create_table "pricing_setups", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "organization_id"
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

  create_table "professional_organizations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.text "name"
    t.string "org_type"
    t.bigint "parent_id"
  end

  create_table "project_roles", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "protocol_id"
    t.bigint "identity_id"
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

  create_table "protocol_filters", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "identity_id"
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

  create_table "protocol_merges", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "master_protocol_id"
    t.integer "merged_protocol_id"
    t.integer "identity_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "protocols", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "type"
    t.integer "next_ssr_id"
    t.string "short_title"
    t.text "title"
    t.string "sponsor_name"
    t.text "brief_description"
    t.decimal "indirect_cost_rate", precision: 6, scale: 2
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
    t.datetime "initial_budget_sponsor_received_date"
    t.datetime "budget_agreed_upon_date"
    t.bigint "initial_amount"
    t.bigint "initial_amount_clinical_services"
    t.bigint "negotiated_amount"
    t.bigint "negotiated_amount_clinical_services"
    t.string "billing_business_manager_static_email"
    t.datetime "recruitment_start_date"
    t.datetime "recruitment_end_date"
    t.boolean "selected_for_epic"
    t.boolean "archived", default: false
    t.bigint "study_type_question_group_id"
    t.integer "research_master_id"
    t.integer "sub_service_requests_count", default: 0
    t.boolean "rmid_validated", default: false
    t.boolean "locked"
    t.string "guarantor_contact"
    t.string "guarantor_phone"
    t.string "guarantor_email"
    t.index ["next_ssr_id"], name: "index_protocols_on_next_ssr_id"
  end

  create_table "protocols_study_phases", id: false, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "protocol_id", null: false
    t.bigint "study_phase_id", null: false
    t.index ["protocol_id", "study_phase_id"], name: "index_protocols_study_phases_on_protocol_id_and_study_phase_id"
    t.index ["study_phase_id", "protocol_id"], name: "index_protocols_study_phases_on_study_phase_id_and_protocol_id"
  end

  create_table "question_responses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "question_id"
    t.bigint "response_id"
    t.text "content"
    t.boolean "required", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_question_responses_on_question_id"
    t.index ["response_id"], name: "index_question_responses_on_response_id"
  end

  create_table "questions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "section_id"
    t.boolean "is_dependent", null: false
    t.text "content", null: false
    t.string "question_type", null: false
    t.text "description"
    t.boolean "required", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "depender_id"
    t.index ["depender_id"], name: "index_questions_on_depender_id"
    t.index ["section_id"], name: "index_questions_on_section_id"
  end

  create_table "quick_questions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "to"
    t.string "from"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reports", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "sub_service_request_id"
    t.string "xlsx_file_name"
    t.string "xlsx_content_type"
    t.integer "xlsx_file_size"
    t.datetime "xlsx_updated_at"
    t.string "report_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "research_types_info", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "protocol_id"
    t.boolean "human_subjects"
    t.boolean "vertebrate_animals"
    t.boolean "investigational_products"
    t.boolean "ip_patents"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["protocol_id"], name: "index_research_types_info_on_protocol_id"
  end

  create_table "response_filters", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "identity_id"
    t.string "name"
    t.string "of_type"
    t.string "with_state"
    t.string "with_survey"
    t.string "start_date"
    t.string "end_date"
    t.boolean "include_incomplete"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "responses", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "survey_id"
    t.bigint "identity_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "respondable_id"
    t.string "respondable_type"
    t.index ["identity_id"], name: "index_responses_on_identity_id"
    t.index ["respondable_id", "respondable_type"], name: "index_responses_on_respondable_id_and_respondable_type"
    t.index ["survey_id"], name: "index_responses_on_survey_id"
  end

  create_table "revenue_code_ranges", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "from"
    t.integer "to"
    t.float "percentage"
    t.bigint "applied_org_id"
    t.string "vendor"
    t.integer "version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sections", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "survey_id"
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["survey_id"], name: "index_sections_on_survey_id"
  end

  create_table "service_providers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "identity_id"
    t.bigint "organization_id"
    t.boolean "is_primary_contact"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "hold_emails"
    t.datetime "deleted_at"
    t.index ["identity_id"], name: "index_service_providers_on_identity_id"
    t.index ["organization_id"], name: "index_service_providers_on_organization_id"
  end

  create_table "service_relations", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "service_id"
    t.bigint "related_service_id"
    t.boolean "required"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["related_service_id"], name: "index_service_relations_on_related_service_id"
    t.index ["service_id"], name: "index_service_relations_on_service_id"
  end

  create_table "service_requests", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "protocol_id"
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

  create_table "services", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "abbreviation"
    t.integer "order"
    t.text "description"
    t.boolean "is_available", default: true
    t.decimal "service_center_cost", precision: 12, scale: 4
    t.string "cpt_code"
    t.string "charge_code"
    t.string "revenue_code"
    t.bigint "organization_id"
    t.string "order_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.boolean "send_to_epic", default: false
    t.bigint "revenue_code_range_id"
    t.boolean "one_time_fee", default: false
    t.integer "line_items_count", default: 0
    t.text "components"
    t.string "eap_id"
    t.index ["is_available"], name: "index_services_on_is_available"
    t.index ["one_time_fee"], name: "index_services_on_one_time_fee"
    t.index ["organization_id"], name: "index_services_on_organization_id"
  end

  create_table "sessions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id"
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "settings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "key"
    t.text "value"
    t.string "data_type"
    t.string "friendly_name"
    t.text "description"
    t.string "group"
    t.string "version"
    t.string "parent_key"
    t.string "parent_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_settings_on_key", unique: true
  end

  create_table "short_interactions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "identity_id"
    t.string "name"
    t.string "email"
    t.string "institution"
    t.integer "duration_in_minutes"
    t.string "subject"
    t.text "note"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "interaction_type"
    t.index ["identity_id"], name: "index_short_interactions_on_identity_id"
  end

  create_table "study_phases", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "order"
    t.string "phase"
    t.integer "version", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "study_type_answers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "protocol_id"
    t.bigint "study_type_question_id"
    t.boolean "answer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "study_type_question_groups", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "version"
    t.boolean "active", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "study_type_questions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "order"
    t.text "question"
    t.string "friendly_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "study_type_question_group_id"
  end

  create_table "study_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "protocol_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["protocol_id"], name: "index_study_types_on_protocol_id"
  end

  create_table "sub_service_requests", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "service_request_id"
    t.bigint "organization_id"
    t.bigint "owner_id"
    t.string "ssr_id"
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
    t.bigint "service_requester_id"
    t.datetime "submitted_at"
    t.bigint "protocol_id"
    t.boolean "imported_to_fulfillment", default: false
    t.index ["organization_id"], name: "index_sub_service_requests_on_organization_id"
    t.index ["owner_id"], name: "index_sub_service_requests_on_owner_id"
    t.index ["protocol_id"], name: "index_sub_service_requests_on_protocol_id"
    t.index ["service_request_id"], name: "index_sub_service_requests_on_service_request_id"
    t.index ["service_requester_id"], name: "index_sub_service_requests_on_service_requester_id"
    t.index ["ssr_id"], name: "index_sub_service_requests_on_ssr_id"
    t.index ["status"], name: "index_sub_service_requests_on_status"
  end

  create_table "submission_emails", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "organization_id"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["organization_id"], name: "index_submission_emails_on_organization_id"
  end

  create_table "subsidies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.boolean "overridden"
    t.bigint "sub_service_request_id"
    t.integer "total_at_approval"
    t.string "status", default: "Pending"
    t.bigint "approved_by"
    t.datetime "approved_at"
    t.float "percent_subsidy", default: 0.0
    t.index ["sub_service_request_id"], name: "index_subsidies_on_sub_service_request_id"
  end

  create_table "subsidy_maps", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "organization_id"
    t.decimal "max_dollar_cap", precision: 12, scale: 4, default: "0.0"
    t.decimal "max_percentage", precision: 5, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.float "default_percentage", default: 0.0
    t.text "instructions"
    t.index ["organization_id"], name: "index_subsidy_maps_on_organization_id"
  end

  create_table "super_users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "identity_id"
    t.bigint "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.boolean "access_empty_protocols", default: false
    t.index ["identity_id"], name: "index_super_users_on_identity_id"
    t.index ["organization_id"], name: "index_super_users_on_organization_id"
  end

  create_table "surveys", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.string "access_code", null: false
    t.integer "version", null: false
    t.boolean "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.bigint "surveyable_id"
    t.string "surveyable_type"
    t.index ["surveyable_id", "surveyable_type"], name: "index_surveys_on_surveyable_id_and_surveyable_type"
  end

  create_table "taggings", id: :bigint, default: nil, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "tag_id"
    t.bigint "taggable_id"
    t.string "taggable_type"
    t.bigint "tagger_id"
    t.string "tagger_type"
    t.string "context", limit: 128
    t.datetime "created_at"
    t.index ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
    t.index ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
    t.index ["tagger_id"], name: "index_taggings_on_tagger_id"
  end

  create_table "tags", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "tokens", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "service_request_id"
    t.bigint "identity_id"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["identity_id"], name: "index_tokens_on_identity_id"
    t.index ["service_request_id"], name: "index_tokens_on_service_request_id"
  end

  create_table "vertebrate_animals_info", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.bigint "protocol_id"
    t.string "iacuc_number"
    t.string "name_of_iacuc"
    t.datetime "iacuc_approval_date"
    t.datetime "iacuc_expiration_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["protocol_id"], name: "index_vertebrate_animals_info_on_protocol_id"
  end

  create_table "visit_groups", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.bigint "arm_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.integer "day"
    t.integer "window_before", default: 0
    t.integer "window_after", default: 0
    t.index ["arm_id"], name: "index_visit_groups_on_arm_id"
  end

  create_table "visits", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "quantity", default: 0
    t.string "billing"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.integer "research_billing_qty", default: 0
    t.integer "insurance_billing_qty", default: 0
    t.integer "effort_billing_qty", default: 0
    t.bigint "line_items_visit_id"
    t.bigint "visit_group_id"
    t.index ["line_items_visit_id"], name: "index_visits_on_line_items_visit_id"
    t.index ["research_billing_qty"], name: "index_visits_on_research_billing_qty"
    t.index ["visit_group_id"], name: "index_visits_on_visit_group_id"
  end

  add_foreign_key "editable_statuses", "organizations"
  add_foreign_key "options", "questions"
  add_foreign_key "question_responses", "questions"
  add_foreign_key "question_responses", "responses"
  add_foreign_key "questions", "options", column: "depender_id"
  add_foreign_key "questions", "sections"
  add_foreign_key "responses", "identities"
  add_foreign_key "responses", "surveys"
  add_foreign_key "sections", "surveys"
end
