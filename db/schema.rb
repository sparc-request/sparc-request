# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_02_12_152129) do

  create_table "databases", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.bigint "university_id"
    t.string "name_ciphertext"
    t.string "host_ciphertext"
    t.string "username_ciphertext"
    t.string "password_ciphertext"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["university_id"], name: "index_databases_on_university_id"
  end

  create_table "identities", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "ldap_uid"
    t.string "email"
    t.string "last_name"
    t.string "first_name"
    t.string "phone"
    t.text "reason"
    t.string "company"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "orcid", limit: 19
    t.boolean "approved", default: false, null: false
    t.index ["approved"], name: "index_identities_on_approved"
    t.index ["email"], name: "index_identities_on_email"
    t.index ["last_name"], name: "index_identities_on_last_name"
    t.index ["ldap_uid"], name: "index_identities_on_ldap_uid", unique: true
    t.index ["reset_password_token"], name: "index_identities_on_reset_password_token", unique: true
  end

  create_table "sessions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["session_id"], name: "index_sessions_on_session_id"
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "settings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "key"
    t.text "value"
    t.string "data_type"
    t.string "friendly_name"
    t.text "description"
    t.integer "group"
    t.string "version"
    t.string "parent_key"
    t.string "parent_value"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["key"], name: "index_settings_on_key", unique: true
  end

  create_table "universities", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "key"
    t.string "name"
    t.index ["key"], name: "index_universities_on_key"
  end

end
