# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2024_01_29_154925) do

  create_table "active_storage_attachments", charset: "utf8mb3", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb3", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "additional_funding_sources", charset: "utf8mb3", force: :cascade do |t|
    t.string "funding_source"
    t.string "funding_source_other"
    t.string "sponsor_name"
    t.text "comments"
    t.string "federal_grant_code"
    t.string "federal_grant_serial_number"
    t.string "federal_grant_title"
    t.string "phs_sponsor"
    t.string "non_phs_sponsor"
    t.bigint "protocol_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["protocol_id"], name: "index_additional_funding_sources_on_protocol_id"
  end

  create_table "admin_rate_changes", charset: "utf8mb3", force: :cascade do |t|
    t.bigint "line_item_id"
    t.bigint "identity_id"
    t.integer "admin_cost"
    t.boolean "cost_reset", default: false
    t.datetime "date_of_change"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["identity_id"], name: "index_admin_rate_changes_on_identity_id"
    t.index ["line_item_id"], name: "index_admin_rate_changes_on_line_item_id"
  end

  create_table "admin_rates", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "line_item_id"
    t.integer "admin_cost"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "identity_id"
  end

  create_table "affiliations", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "protocol_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["protocol_id"], name: "index_affiliations_on_protocol_id"
  end

  create_table "alerts", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "alert_type"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "applications", charset: "utf8mb3", collation: "utf8mb3_bin", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "domain"
    t.text "token_ciphertext"
    t.datetime "created_at", null: false
    t.bigint "created_by"
    t.datetime "updated_at", null: false
    t.index ["created_by"], name: "index_applications_on_created_by"
  end

  create_table "approvals", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "identity_id"
    t.datetime "approval_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "approval_type", default: "Resource Approval"
    t.bigint "sub_service_request_id"
    t.index ["identity_id"], name: "index_approvals_on_identity_id"
    t.index ["sub_service_request_id"], name: "index_approvals_on_sub_service_request_id"
  end

  create_table "arms", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
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

  create_table "associated_surveys", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "associable_id"
    t.string "associable_type"
    t.bigint "survey_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["associable_id"], name: "index_associated_surveys_on_associable_id"
    t.index ["survey_id"], name: "index_associated_surveys_on_survey_id"
  end

  create_table "audits", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
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

  create_table "available_statuses", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "organization_id"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "selected", default: false
    t.index ["organization_id"], name: "index_available_statuses_on_organization_id"
  end

  create_table "catalog_managers", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "identity_id"
    t.bigint "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.boolean "edit_historic_data"
    t.index ["identity_id"], name: "index_catalog_managers_on_identity_id"
    t.index ["organization_id"], name: "index_catalog_managers_on_organization_id"
  end

  create_table "charges", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "service_request_id"
    t.bigint "service_id"
    t.decimal "charge_amount", precision: 12, scale: 4
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["service_id"], name: "index_charges_on_service_id"
    t.index ["service_request_id"], name: "index_charges_on_service_request_id"
  end

  create_table "clinical_providers", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "identity_id"
    t.bigint "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["identity_id"], name: "index_clinical_providers_on_identity_id"
    t.index ["organization_id"], name: "index_clinical_providers_on_organization_id"
  end

  create_table "cover_letters", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.text "content"
    t.bigint "sub_service_request_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sub_service_request_id"], name: "index_cover_letters_on_sub_service_request_id"
  end

  create_table "delayed_jobs", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", size: :long, null: false
    t.text "last_error", size: :long
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "documents", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.datetime "deleted_at"
    t.string "doc_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "doc_type_other"
    t.bigint "protocol_id"
    t.boolean "share_all"
    t.date "version"
    t.index ["protocol_id"], name: "index_documents_on_protocol_id"
  end

  create_table "documents_sub_service_requests", id: false, charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "document_id"
    t.bigint "sub_service_request_id"
  end

  create_table "editable_statuses", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "organization_id"
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "selected", default: false
    t.index ["organization_id"], name: "index_editable_statuses_on_organization_id"
  end

  create_table "epic_queue_records", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "protocol_id"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "origin"
    t.bigint "identity_id"
  end

  create_table "epic_queues", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "protocol_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "identity_id"
    t.boolean "attempted_push", default: false
    t.boolean "user_change", default: false
  end

  create_table "epic_rights", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "project_role_id"
    t.string "right"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "excluded_funding_sources", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "subsidy_map_id"
    t.string "funding_source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["subsidy_map_id"], name: "index_excluded_funding_sources_on_subsidy_map_id"
  end

  create_table "external_organizations", charset: "utf8mb3", collation: "utf8mb3_bin", force: :cascade do |t|
    t.string "collaborating_org_name"
    t.string "collaborating_org_type"
    t.text "comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "protocol_id"
    t.string "collaborating_org_name_other"
    t.string "collaborating_org_type_other"
    t.index ["protocol_id"], name: "index_external_organizations_on_protocol_id"
  end

  create_table "feedbacks", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.text "message"
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fulfillment_synchronizations", charset: "utf8mb3", collation: "utf8mb3_bin", force: :cascade do |t|
    t.bigint "sub_service_request_id"
    t.integer "line_item_id"
    t.string "action"
    t.boolean "synched", default: false
    t.index ["sub_service_request_id"], name: "index_fulfillment_synchronizations_on_sub_service_request_id"
  end

  create_table "fulfillments", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
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

  create_table "human_subjects_info", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "protocol_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "nct_number"
    t.index ["protocol_id"], name: "index_human_subjects_info_on_protocol_id"
  end

  create_table "identities", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
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
    t.boolean "imported_from_lbb", default: false
    t.string "age_group"
    t.string "gender"
    t.text "institution"
    t.string "ethnicity"
    t.string "gender_other"
    t.index ["approved"], name: "index_identities_on_approved"
    t.index ["email"], name: "index_identities_on_email"
    t.index ["first_name"], name: "index_identities_on_first_name"
    t.index ["institution"], name: "index_identities_on_institution", length: 55
    t.index ["last_name"], name: "index_identities_on_last_name"
    t.index ["ldap_uid"], name: "index_identities_on_ldap_uid", unique: true
    t.index ["reset_password_token"], name: "index_identities_on_reset_password_token", unique: true
  end

  create_table "impact_areas", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "protocol_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.string "other_text"
    t.index ["protocol_id"], name: "index_impact_areas_on_protocol_id"
  end

  create_table "investigational_products_info", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
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

  create_table "ip_patents_info", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "protocol_id"
    t.string "patent_number"
    t.text "inventors"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["protocol_id"], name: "index_ip_patents_info_on_protocol_id"
  end

  create_table "irb_records", charset: "utf8mb3", collation: "utf8mb3_bin", force: :cascade do |t|
    t.bigint "human_subjects_info_id"
    t.integer "rmid_id"
    t.string "pro_number"
    t.string "irb_of_record"
    t.string "submission_type"
    t.date "initial_irb_approval_date"
    t.date "irb_approval_date"
    t.date "irb_expiration_date"
    t.boolean "approval_pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["human_subjects_info_id"], name: "index_irb_records_on_human_subjects_info_id"
  end

  create_table "irb_records_study_phases", id: false, charset: "utf8mb3", collation: "utf8mb3_bin", force: :cascade do |t|
    t.bigint "irb_record_id"
    t.bigint "study_phase_id"
    t.index ["irb_record_id"], name: "index_irb_records_study_phases_on_irb_record_id"
    t.index ["study_phase_id"], name: "index_irb_records_study_phases_on_study_phase_id"
  end

  create_table "line_items", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
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

  create_table "line_items_visits", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "arm_id"
    t.bigint "line_item_id"
    t.integer "subject_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "visit_r_quantity", default: 0
    t.integer "visit_i_quantity", default: 0
    t.integer "visit_e_quantity", default: 0
    t.index ["arm_id"], name: "index_line_items_visits_on_arm_id"
    t.index ["line_item_id"], name: "index_line_items_visits_on_line_item_id"
  end

  create_table "messages", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
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

  create_table "notes", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
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

  create_table "notifications", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "sub_service_request_id"
    t.bigint "originator_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "subject"
    t.bigint "other_user_id"
    t.boolean "read_by_originator"
    t.boolean "read_by_other_user"
    t.boolean "shared"
    t.index ["originator_id"], name: "index_notifications_on_originator_id"
    t.index ["sub_service_request_id"], name: "index_notifications_on_sub_service_request_id"
  end

  create_table "oauth_access_grants", charset: "utf8mb3", collation: "utf8mb3_bin", force: :cascade do |t|
    t.bigint "resource_owner_id", null: false
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_requests", charset: "utf8mb3", collation: "utf8mb3_bin", force: :cascade do |t|
    t.bigint "application_id"
    t.bigint "access_token_id"
    t.string "ip_address", null: false
    t.string "status", null: false
    t.text "failure_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["access_token_id"], name: "index_oauth_access_requests_on_access_token_id"
    t.index ["application_id"], name: "index_oauth_access_requests_on_application_id"
  end

  create_table "oauth_access_tokens", charset: "utf8mb3", collation: "utf8mb3_bin", force: :cascade do |t|
    t.bigint "resource_owner_id"
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", charset: "utf8mb3", collation: "utf8mb3_bin", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri"
    t.string "scopes", default: "", null: false
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "oncore_records", charset: "utf8mb3", collation: "utf8mb3_bin", force: :cascade do |t|
    t.bigint "protocol_id"
    t.integer "calendar_version"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["protocol_id"], name: "index_oncore_records_on_protocol_id"
  end

  create_table "options", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "question_id"
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_options_on_question_id"
  end

  create_table "organizations", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
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
    t.boolean "survey_completion_alerts", default: false
    t.index ["is_available"], name: "index_organizations_on_is_available"
    t.index ["parent_id"], name: "index_organizations_on_parent_id"
  end

  create_table "past_statuses", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
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

  create_table "past_subsidies", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
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

  create_table "patient_registrars", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "identity_id"
    t.bigint "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["identity_id"], name: "index_patient_registrars_on_identity_id"
    t.index ["organization_id"], name: "index_patient_registrars_on_organization_id"
  end

  create_table "payment_uploads", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "payment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_id"], name: "index_payment_uploads_on_payment_id"
  end

  create_table "payments", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
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

  create_table "permissible_values", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
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

  create_table "pricing_maps", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
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

  create_table "pricing_setups", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
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

  create_table "professional_organizations", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.text "name"
    t.string "org_type"
    t.bigint "parent_id"
  end

  create_table "project_roles", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
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

  create_table "protocol_filters", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
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

  create_table "protocol_merges", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.integer "master_protocol_id"
    t.integer "merged_protocol_id"
    t.integer "identity_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "protocols", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "type"
    t.bigint "next_ssr_id"
    t.string "short_title"
    t.text "title"
    t.string "sponsor_name"
    t.text "brief_description"
    t.decimal "indirect_cost_rate", precision: 6, scale: 2
    t.string "study_phase"
    t.string "udak_project_number"
    t.string "funding_rfa"
    t.string "funding_status"
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
    t.string "default_billing_type", default: "r"
    t.boolean "show_additional_funding_sources"
    t.index ["next_ssr_id"], name: "index_protocols_on_next_ssr_id"
  end

  create_table "question_responses", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "question_id"
    t.bigint "response_id"
    t.text "content"
    t.boolean "required", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_question_responses_on_question_id"
    t.index ["response_id"], name: "index_question_responses_on_response_id"
  end

  create_table "questions", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
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

  create_table "quick_questions", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "to"
    t.string "from"
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "races", charset: "utf8mb3", collation: "utf8mb3_bin", force: :cascade do |t|
    t.bigint "identity_id"
    t.string "name", null: false
    t.string "other_text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["identity_id"], name: "index_races_on_identity_id"
  end

  create_table "reports", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "sub_service_request_id"
    t.string "report_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "research_types_info", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
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

  create_table "response_filters", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
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

  create_table "responses", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
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

  create_table "revenue_code_ranges", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.integer "from"
    t.integer "to"
    t.float "percentage"
    t.bigint "applied_org_id"
    t.string "vendor"
    t.integer "version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sections", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "survey_id"
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["survey_id"], name: "index_sections_on_survey_id"
  end

  create_table "service_providers", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
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

  create_table "service_relations", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "service_id"
    t.bigint "related_service_id"
    t.boolean "required"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["related_service_id"], name: "index_service_relations_on_related_service_id"
    t.index ["service_id"], name: "index_service_relations_on_service_id"
  end

  create_table "service_requests", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "protocol_id"
    t.string "status"
    t.datetime "submitted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.date "original_submitted_date"
    t.index ["protocol_id"], name: "index_service_requests_on_protocol_id"
    t.index ["status"], name: "index_service_requests_on_status"
  end

  create_table "services", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
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

  create_table "sessions", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id"
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "settings", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
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

  create_table "short_interactions", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
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

  create_table "study_phases", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.integer "order"
    t.string "phase"
    t.integer "version", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "study_type_answers", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "protocol_id"
    t.bigint "study_type_question_id"
    t.boolean "answer"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "study_type_question_groups", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.integer "version"
    t.boolean "active", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "study_type_questions", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.integer "order"
    t.text "question"
    t.string "friendly_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "study_type_question_group_id"
  end

  create_table "study_types", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "protocol_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["protocol_id"], name: "index_study_types_on_protocol_id"
  end

  create_table "sub_service_requests", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
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
    t.boolean "in_work_fulfillment", default: false
    t.string "routing"
    t.text "org_tree_display"
    t.bigint "service_requester_id"
    t.datetime "submitted_at"
    t.bigint "recent_submitted_by"
    t.bigint "protocol_id"
    t.boolean "imported_to_fulfillment", default: false
    t.boolean "synch_to_fulfillment"
    t.index ["organization_id"], name: "index_sub_service_requests_on_organization_id"
    t.index ["owner_id"], name: "index_sub_service_requests_on_owner_id"
    t.index ["protocol_id"], name: "index_sub_service_requests_on_protocol_id"
    t.index ["recent_submitted_by"], name: "index_sub_service_requests_on_recent_submitted_by"
    t.index ["service_request_id"], name: "index_sub_service_requests_on_service_request_id"
    t.index ["service_requester_id"], name: "index_sub_service_requests_on_service_requester_id"
    t.index ["ssr_id"], name: "index_sub_service_requests_on_ssr_id"
    t.index ["status"], name: "index_sub_service_requests_on_status"
  end

  create_table "submission_emails", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "organization_id"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["organization_id"], name: "index_submission_emails_on_organization_id"
  end

  create_table "subsidies", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
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

  create_table "subsidy_maps", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
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

  create_table "super_users", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "identity_id"
    t.bigint "organization_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.boolean "access_empty_protocols", default: false
    t.boolean "billing_manager"
    t.boolean "allow_credit"
    t.boolean "hold_emails", default: true
    t.index ["identity_id"], name: "index_super_users_on_identity_id"
    t.index ["organization_id"], name: "index_super_users_on_organization_id"
  end

  create_table "surveys", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.string "access_code", null: false
    t.integer "version", null: false
    t.boolean "active", null: false
    t.string "notify_roles"
    t.boolean "notify_requester", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.bigint "surveyable_id"
    t.string "surveyable_type"
    t.index ["surveyable_id", "surveyable_type"], name: "index_surveys_on_surveyable_id_and_surveyable_type"
  end

  create_table "taggings", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
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

  create_table "tags", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.integer "taggings_count", default: 0
    t.index ["name"], name: "index_tags_on_name", unique: true
  end

  create_table "tokens", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.bigint "service_request_id"
    t.bigint "identity_id"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.index ["identity_id"], name: "index_tokens_on_identity_id"
    t.index ["service_request_id"], name: "index_tokens_on_service_request_id"
  end

  create_table "vertebrate_animals_info", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
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

  create_table "visit_groups", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
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

  create_table "visits", charset: "utf8mb3", collation: "utf8mb3_unicode_ci", force: :cascade do |t|
    t.integer "quantity", default: 0
    t.string "billing"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.bigint "research_billing_qty", default: 0
    t.integer "insurance_billing_qty", default: 0
    t.integer "effort_billing_qty", default: 0
    t.bigint "line_items_visit_id"
    t.bigint "visit_group_id"
    t.index ["line_items_visit_id"], name: "index_visits_on_line_items_visit_id"
    t.index ["research_billing_qty"], name: "index_visits_on_research_billing_qty"
    t.index ["visit_group_id"], name: "index_visits_on_visit_group_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "additional_funding_sources", "protocols"
  add_foreign_key "editable_statuses", "organizations"
  add_foreign_key "external_organizations", "protocols"
  add_foreign_key "oauth_access_grants", "identities", column: "resource_owner_id"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_requests", "oauth_access_tokens", column: "access_token_id"
  add_foreign_key "oauth_access_requests", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "identities", column: "resource_owner_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "options", "questions"
  add_foreign_key "question_responses", "questions"
  add_foreign_key "question_responses", "responses"
  add_foreign_key "questions", "options", column: "depender_id"
  add_foreign_key "questions", "sections"
  add_foreign_key "responses", "identities"
  add_foreign_key "responses", "surveys"
  add_foreign_key "sections", "surveys"
end
