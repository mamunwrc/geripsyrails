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

ActiveRecord::Schema.define(version: 20230330093805) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_stat_statements"

  create_table "adm_cpt_prices", force: :cascade do |t|
    t.text "cpt_code"
    t.money "price", scale: 2
    t.index ["cpt_code"], name: "index_adm_cpt_prices_on_cpt_code"
  end

  create_table "adm_facilities", id: :serial, force: :cascade do |t|
    t.string "name", limit: 32
    t.integer "facility_type"
    t.string "admin_last_name", limit: 64
    t.string "admin_first_name", limit: 64
    t.string "admin_middle_name", limit: 64
    t.string "admin_title", limit: 32
    t.string "admin_email", limit: 256
    t.string "suffix", limit: 32
    t.string "address1", limit: 64
    t.string "address2", limit: 64
    t.string "city", limit: 64
    t.string "state", limit: 3
    t.string "zip", limit: 15
    t.string "home_phone", limit: 32
    t.string "work_phone", limit: 32
    t.string "email", limit: 256
    t.string "npi", limit: 12
    t.boolean "send_alerts", default: false
    t.string "status", limit: 8
    t.text "xml_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "country"
    t.integer "practice_id"
    t.integer "medicare", default: 1
    t.integer "hp_alt_pos_code"
    t.integer "hp_main_pos_code"
    t.index ["medicare"], name: "index_adm_facilities_on_medicare"
    t.index ["practice_id"], name: "index_adm_facilities_on_practice_id"
  end

  create_table "adm_facility_contacts", id: :serial, force: :cascade do |t|
    t.integer "export_format", default: 0
    t.integer "export_type", default: 0
    t.integer "facility_id"
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active", default: true
    t.index ["facility_id"], name: "index_adm_facility_contacts_on_facility_id"
  end

  create_table "adm_facility_doctors", id: :serial, force: :cascade do |t|
    t.string "name"
    t.integer "facility_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["facility_id"], name: "index_adm_facility_doctors_on_facility_id"
  end

  create_table "adm_practices", id: :serial, force: :cascade do |t|
    t.string "name", limit: 32
    t.integer "practice_type", default: 0
    t.string "status", limit: 8
    t.string "admin_last_name", limit: 64
    t.string "admin_first_name", limit: 64
    t.string "admin_middle_name", limit: 64
    t.string "admin_title", limit: 32
    t.string "admin_email", limit: 256
    t.string "admin_suffix", limit: 32
    t.string "address1", limit: 64
    t.string "address2", limit: 64
    t.string "city", limit: 64
    t.string "zip", limit: 15
    t.string "county", limit: 64
    t.string "home_phone", limit: 16
    t.string "work_phone", limit: 16
    t.string "email", limit: 256
    t.string "npi", limit: 12
    t.string "medicare_id", limit: 32
    t.string "medicaid_id", limit: 32
    t.string "hmo_id", limit: 32
    t.boolean "send_alerts"
    t.text "xml_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "admin_id"
    t.string "tax_number", limit: 30
    t.integer "state"
    t.integer "reviewer_id"
    t.integer "email_format", default: 0
    t.string "remit_token"
    t.index ["admin_id"], name: "index_adm_practices_on_admin_id"
    t.index ["remit_token"], name: "index_adm_practices_on_remit_token", unique: true
    t.index ["reviewer_id"], name: "index_adm_practices_on_reviewer_id"
  end

  create_table "adm_remit_batches", force: :cascade do |t|
    t.datetime "batch_date"
    t.jsonb "payload"
    t.inet "ip"
    t.integer "practice_id"
    t.string "token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["practice_id"], name: "index_adm_remit_batches_on_practice_id"
  end

  create_table "adm_remits", force: :cascade do |t|
    t.datetime "posted_on"
    t.integer "provider_id"
    t.integer "status"
    t.string "batch"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "practice_id"
    t.boolean "shipped", default: false
    t.integer "remit_batch_id"
    t.index ["posted_on", "batch"], name: "index_adm_remits_on_posted_on_and_batch", unique: true
    t.index ["practice_id"], name: "index_adm_remits_on_practice_id"
    t.index ["remit_batch_id"], name: "index_adm_remits_on_remit_batch_id"
  end

  create_table "audits", id: :serial, force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.jsonb "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_id", "associated_type"], name: "associated_index"
    t.index ["auditable_id", "auditable_type"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
  end

  create_table "enc_addendums", id: :serial, force: :cascade do |t|
    t.text "note"
    t.integer "encounter_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["encounter_id"], name: "index_enc_addendums_on_encounter_id"
  end

  create_table "enc_encounter_assessments", id: :serial, force: :cascade do |t|
    t.integer "encounter_id", null: false
    t.string "sno_code", limit: 18
    t.string "icd_code", limit: 8
    t.string "description", limit: 256
    t.string "assessment_status", limit: 32
    t.string "category", limit: 64
    t.text "comment"
    t.integer "provider_id"
    t.integer "recorded_by"
    t.datetime "recorded_on"
    t.integer "category_rank"
    t.integer "assessment_rank"
    t.text "xml_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["encounter_id"], name: "index_enc_encounter_assessments_on_encounter_id"
  end

  create_table "enc_encounter_notes", id: :serial, force: :cascade do |t|
    t.integer "encounter_id"
    t.integer "patient_id"
    t.integer "provider_id"
    t.integer "note_type"
    t.string "note_status", limit: 16
    t.integer "template_id"
    t.string "note_section_type", limit: 32
    t.integer "note_section_seq"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["encounter_id"], name: "index_enc_encounter_notes_on_encounter_id"
    t.index ["patient_id"], name: "index_enc_encounter_notes_on_patient_id"
    t.index ["provider_id"], name: "index_enc_encounter_notes_on_provider_id"
  end

  create_table "enc_encounters", id: :serial, force: :cascade do |t|
    t.integer "patient_id"
    t.integer "provider_id"
    t.integer "facility_id"
    t.string "cpt_encounter_code", limit: 5
    t.string "place_of_service_code", limit: 2
    t.string "encounter_code", limit: 32
    t.string "encounter_title", limit: 256
    t.string "encounter_type", limit: 256
    t.string "chief_complaint", limit: 256
    t.string "encounter_status", limit: 12
    t.integer "encounter_duration"
    t.datetime "encounter_start"
    t.datetime "encounter_end"
    t.boolean "confidentiality"
    t.string "location", limit: 256
    t.integer "recorded_by"
    t.datetime "recorded_on"
    t.text "note"
    t.text "xml_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "encounter_data"
    t.datetime "signed_on"
    t.integer "signed_by"
    t.text "shipped_hp_billing"
    t.json "tp_methods"
    t.json "background_history"
    t.json "certification"
    t.json "diagnosis"
    t.json "functional_status"
    t.json "plan"
    t.json "problem"
    t.json "progress"
    t.json "referral"
    t.json "therapeutic_communication"
    t.json "competency"
    t.json "goals"
    t.json "group_data"
    t.boolean "unbilled", default: false
    t.text "code_modifier"
    t.integer "facility_pos_code"
    t.jsonb "testing_note_hp_cache", default: {"files"=>[]}
    t.boolean "is_custom_code_modifier", default: false
    t.integer "incident_to_provider_id"
    t.index ["patient_id"], name: "index_enc_encounters_on_patient_id"
    t.index ["provider_id"], name: "index_enc_encounters_on_provider_id"
  end

  create_table "enc_screenings", id: :serial, force: :cascade do |t|
    t.json "axes"
    t.integer "screening_type"
    t.integer "encounter_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["encounter_id"], name: "index_enc_screenings_on_encounter_id"
    t.index ["screening_type"], name: "index_enc_screenings_on_screening_type"
  end

  create_table "facilities_practices", id: false, force: :cascade do |t|
    t.integer "facility_id", null: false
    t.integer "practice_id", null: false
    t.index ["facility_id", "practice_id"], name: "index_facilities_practices_on_facility_id_and_practice_id"
    t.index ["practice_id", "facility_id"], name: "index_facilities_practices_on_practice_id_and_facility_id"
  end

  create_table "grp_addendums", id: :serial, force: :cascade do |t|
    t.text "note"
    t.integer "encounter_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "grp_encounters", id: :serial, force: :cascade do |t|
    t.integer "group_id"
    t.json "group_therapy_session"
    t.json "interventions"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "certification", default: {}
    t.date "signed_on"
    t.integer "signed_by"
    t.integer "provider_id"
    t.index ["group_id"], name: "index_grp_encounters_on_group_id"
    t.index ["signed_by"], name: "index_grp_encounters_on_signed_by"
  end

  create_table "grp_groups", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "practice_id"
    t.string "contact_email"
    t.boolean "contact_active", default: false
    t.index ["practice_id"], name: "index_grp_groups_on_practice_id"
  end

  create_table "grp_leaders", id: :serial, force: :cascade do |t|
    t.integer "provider_id"
    t.integer "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_grp_leaders_on_group_id"
    t.index ["provider_id"], name: "index_grp_leaders_on_provider_id"
  end

  create_table "grp_members", id: :serial, force: :cascade do |t|
    t.integer "group_id"
    t.integer "patient_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_grp_members_on_group_id"
    t.index ["patient_id"], name: "index_grp_members_on_patient_id"
  end

  create_table "grp_note_subjects", id: :serial, force: :cascade do |t|
    t.integer "patient_note_id"
    t.integer "patient_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["patient_id"], name: "index_grp_note_subjects_on_patient_id"
    t.index ["patient_note_id"], name: "index_grp_note_subjects_on_patient_note_id"
  end

  create_table "grp_patient_notes", id: :serial, force: :cascade do |t|
    t.integer "encounter_id"
    t.string "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "confidential", default: false
    t.index ["encounter_id"], name: "index_grp_patient_notes_on_encounter_id"
  end

  create_table "pat_addresses", id: :serial, force: :cascade do |t|
    t.integer "patient_id"
    t.string "patient_code", limit: 32
    t.string "address_type", limit: 32
    t.integer "address_rank"
    t.string "address1", limit: 64
    t.string "address2", limit: 64
    t.string "city", limit: 64
    t.string "state", limit: 3
    t.string "zip", limit: 15
    t.string "home_phone", limit: 16
    t.string "work_phone", limit: 16
    t.string "fax", limit: 16
    t.string "cell", limit: 16
    t.string "alternate_phone", limit: 16
    t.string "email", limit: 12
    t.text "xml_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["patient_id", "address_type"], name: "index_pat_addresses_on_patient_id_and_address_type"
  end

  create_table "pat_contacts", id: :serial, force: :cascade do |t|
    t.integer "patient_id"
    t.integer "contact_type"
    t.string "first_name", limit: 64
    t.string "last_name", limit: 64
    t.string "address1", limit: 64
    t.string "address2", limit: 64
    t.string "city", limit: 64
    t.string "state", limit: 3
    t.string "zip", limit: 15
    t.string "title", limit: 32
    t.string "suffix", limit: 32
    t.string "ssn", limit: 16
    t.datetime "dob"
    t.string "status", limit: 8
    t.string "home_phone", limit: 16
    t.string "work_phone", limit: 16
    t.string "fax", limit: 16
    t.string "cell", limit: 16
    t.string "alternate_phone", limit: 16
    t.string "email", limit: 12
    t.text "xml_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["patient_id", "contact_type"], name: "index_pat_contacts_on_patient_id_and_contact_type"
  end

  create_table "pat_documents", id: :serial, force: :cascade do |t|
    t.integer "patient_id"
    t.integer "provider_id"
    t.string "folder_name", limit: 255
    t.string "document_name", limit: 255
    t.string "document_description", limit: 1024
    t.datetime "document_date"
    t.string "directory", limit: 255
    t.string "file_name", limit: 255
    t.binary "contents"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["folder_name", "document_name"], name: "index_pat_documents_on_folder_name_and_document_name"
    t.index ["patient_id"], name: "index_pat_documents_on_patient_id"
    t.index ["provider_id"], name: "index_pat_documents_on_provider_id"
  end

  create_table "pat_insurances", id: :serial, force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "hp_id_code"
    t.boolean "medicare_hmo", default: false
    t.text "payerid"
    t.string "address1"
    t.string "address2"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.index ["hp_id_code"], name: "index_pat_insurances_on_hp_id_code"
  end

  create_table "pat_medications", id: :serial, force: :cascade do |t|
    t.integer "patient_id"
    t.integer "encounter_id"
    t.integer "provider_id"
    t.integer "medicationType"
    t.boolean "is_administered"
    t.integer "administered_by_provider_id"
    t.string "administered_by_name", limit: 64
    t.string "medication_code", limit: 64
    t.string "NDC", limit: 11
    t.string "description", limit: 255
    t.string "dose_amount", limit: 32
    t.string "dose_form", limit: 32
    t.string "dose_frequency", limit: 32
    t.string "dose_frequencyUnit", limit: 16
    t.string "sig", limit: 255
    t.string "pharmacy_instr", limit: 255
    t.datetime "begin_date"
    t.datetime "end_date"
    t.string "status", limit: 32
    t.string "duration_length", limit: 32
    t.string "duration_unit", limit: 16
    t.string "dispense_qty", limit: 32
    t.string "dispense_qty_unit", limit: 16
    t.boolean "is_allow_substitute"
    t.boolean "refill"
    t.text "comment"
    t.string "deleted_reason", limit: 255
    t.integer "recorded_by"
    t.datetime "recorded_on"
    t.integer "deleted_by"
    t.datetime "deleted_on"
    t.text "xml_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["patient_id"], name: "index_pat_medications_on_patient_id"
  end

  create_table "pat_notes", id: :serial, force: :cascade do |t|
    t.integer "patient_id"
    t.integer "user_id"
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["patient_id"], name: "index_pat_notes_on_patient_id"
    t.index ["user_id"], name: "index_pat_notes_on_user_id"
  end

  create_table "pat_patients", id: :serial, force: :cascade do |t|
    t.string "patient_code", limit: 32
    t.string "mrn", limit: 32
    t.string "last_name", limit: 256
    t.string "first_name", limit: 256
    t.string "middle_name", limit: 256
    t.string "title", limit: 32
    t.string "suffix", limit: 32
    t.string "ssn", limit: 16
    t.datetime "dob"
    t.integer "status", default: 0
    t.string "privacy_status", limit: 32
    t.integer "ethnicity"
    t.integer "race"
    t.integer "language"
    t.integer "marital_status"
    t.string "release_information", limit: 64
    t.datetime "death_date"
    t.string "occupation", limit: 256
    t.string "employer", limit: 256
    t.string "employment_status", limit: 16
    t.string "primary_provider_code", limit: 64
    t.integer "facility_id"
    t.text "note"
    t.text "xml_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "gender", default: 0
    t.boolean "has90791", default: false
    t.integer "practice_id"
    t.json "insurance_data"
    t.string "room_num"
    t.datetime "next_tp"
    t.integer "primary_insurance_id"
    t.integer "secondary_insurance_id"
    t.integer "tertiary_insurance_id"
    t.string "primary_insurance_number"
    t.string "secondary_insurance_number"
    t.string "tertiary_insurance_number"
    t.integer "primary_provider_id"
    t.integer "facility_pos_code", default: 31
    t.integer "testing_provider_id"
    t.text "prior_authorization_number"
    t.integer "incident_to_provider_id"
    t.index ["dob"], name: "index_pat_patients_on_dob"
    t.index ["facility_id"], name: "index_pat_patients_on_facility_id"
    t.index ["first_name"], name: "index_pat_patients_on_first_name"
    t.index ["last_name", "first_name"], name: "index_pat_patients_on_last_name_and_first_name"
    t.index ["mrn"], name: "index_pat_patients_on_mrn"
    t.index ["practice_id"], name: "index_pat_patients_on_practice_id"
    t.index ["primary_insurance_id"], name: "index_pat_patients_on_primary_insurance_id"
    t.index ["primary_provider_id"], name: "index_pat_patients_on_primary_provider_id"
    t.index ["secondary_insurance_id"], name: "index_pat_patients_on_secondary_insurance_id"
    t.index ["ssn"], name: "index_pat_patients_on_ssn"
    t.index ["tertiary_insurance_id"], name: "index_pat_patients_on_tertiary_insurance_id"
  end

  create_table "pat_pfs_histories", id: :serial, force: :cascade do |t|
    t.integer "patient_id", null: false
    t.integer "encounter_id"
    t.integer "provider_id"
    t.integer "history_type", null: false
    t.string "sno_code", limit: 18
    t.string "icd_code", limit: 8
    t.string "cpt_code", limit: 6
    t.string "description", limit: 255
    t.string "category", limit: 255
    t.string "provider_name", limit: 255
    t.datetime "begin_date"
    t.boolean "is_begin_date_approx"
    t.datetime "end_date"
    t.boolean "is_end_date_approx"
    t.text "comment"
    t.string "status", limit: 12
    t.boolean "is_confidential"
    t.string "terminate_reason", limit: 255
    t.string "relationship_sno_code", limit: 18
    t.string "relationship_description", limit: 255
    t.boolean "is_deceased"
    t.integer "family_member_age"
    t.string "family_member_name", limit: 256
    t.string "family_member_age_death", limit: 32
    t.datetime "family_member_birth_date"
    t.integer "recorded_by"
    t.datetime "recorded_on"
    t.integer "deleted_by"
    t.datetime "deleted_on"
    t.text "xml_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["patient_id"], name: "index_pat_pfs_histories_on_patient_id"
  end

  create_table "pat_problems", id: :serial, force: :cascade do |t|
    t.integer "patient_id", null: false
    t.integer "encounter_id"
    t.integer "provider_id"
    t.string "problem_category", limit: 32
    t.string "sno_code", limit: 18
    t.string "icd_code", limit: 8
    t.string "description", limit: 255
    t.string "status", limit: 12
    t.datetime "problem_status_date"
    t.boolean "is_status_date_approx"
    t.string "diagnosed_by", limit: 255
    t.string "diagnosed_provider_id", limit: 255
    t.datetime "begin_date"
    t.boolean "is_begin_date_approx"
    t.datetime "end_date"
    t.boolean "is_end_date_approx"
    t.text "comment"
    t.boolean "is_confidential"
    t.string "terminate_reason", limit: 255
    t.string "chronicity", limit: 3
    t.integer "recorded_by"
    t.datetime "recorded_on"
    t.integer "deleted_by"
    t.datetime "deleted_on"
    t.text "xml_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["patient_id"], name: "index_pat_problems_on_patient_id"
  end

  create_table "pat_surgical_histories", id: :serial, force: :cascade do |t|
    t.string "patient_code", limit: 32
    t.integer "encounter_id"
    t.integer "provider_id"
    t.string "sno_code", limit: 18
    t.string "icd_code", limit: 8
    t.string "cpt_code", limit: 6
    t.string "description", limit: 255
    t.text "diagnosis"
    t.string "category", limit: 255
    t.string "provider_name", limit: 255
    t.datetime "begin_date"
    t.boolean "is_begin_date_approx"
    t.datetime "end_date"
    t.boolean "is_end_date_approx"
    t.text "comment"
    t.string "status", limit: 12
    t.boolean "is_confidential"
    t.integer "rank"
    t.string "severity", limit: 256
    t.string "stability", limit: 256
    t.integer "recorded_by"
    t.datetime "recorded_on"
    t.text "xml_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "patients_providers", id: false, force: :cascade do |t|
    t.integer "patient_id", null: false
    t.integer "provider_id", null: false
    t.index ["patient_id", "provider_id"], name: "index_patients_providers_on_patient_id_and_provider_id"
    t.index ["provider_id", "patient_id"], name: "index_patients_providers_on_provider_id_and_patient_id"
  end

  create_table "practices_users", id: false, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "practice_id", null: false
    t.index ["practice_id", "user_id"], name: "index_practices_users_on_practice_id_and_user_id"
    t.index ["user_id", "practice_id"], name: "index_practices_users_on_user_id_and_practice_id"
  end

  create_table "ref_cpts", id: :serial, force: :cascade do |t|
    t.string "cpt", limit: 5, null: false
    t.string "description", limit: 2048
    t.integer "allotted_time", default: 0
    t.boolean "is_active", default: true
    t.string "detail", limit: 2048
    t.datetime "effective_date"
    t.datetime "expiration_date"
    t.boolean "rx"
    t.boolean "is_common", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cpt"], name: "index_ref_cpts_on_cpt"
  end

  create_table "ref_hcpcs", id: :serial, force: :cascade do |t|
    t.string "code", limit: 5, null: false
    t.string "code_redef_group", limit: 5
    t.string "filler1", limit: 3
    t.string "modifier_code", limit: 2
    t.string "seq_number", limit: 5
    t.string "record_identification_code", limit: 1
    t.string "description", limit: 80
    t.string "short_description", limit: 28
    t.string "pricing_indicator_code", limit: 2
    t.string "mult_pricing_indicator_code", limit: 1
    t.string "issues_ref_section", limit: 6
    t.string "carriers_ref_section", limit: 8
    t.string "statute_number", limit: 10
    t.string "lab_cert_code", limit: 3
    t.string "cross_reference_code", limit: 5
    t.string "coverage_code", limit: 1
    t.string "payment_group_code", limit: 2
    t.string "payment_group_effective_date", limit: 8
    t.string "mog_payment_group_code", limit: 3
    t.string "mog_payment_policy_indicator", limit: 1
    t.string "mog_effective_date", limit: 8
    t.string "process_note_number", limit: 4
    t.string "berenson_eggers_tos_code", limit: 3
    t.string "filler2", limit: 1
    t.string "tos_code", limit: 1
    t.string "anesthesia_base_unit_qty", limit: 3
    t.string "code_added_date", limit: 8
    t.string "effective_date", limit: 8
    t.string "termination_date", limit: 8
    t.string "action_code", limit: 1
    t.string "filler3", limit: 27
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_ref_hcpcs_on_code"
  end

  create_table "ref_icds", id: :serial, force: :cascade do |t|
    t.string "icd", null: false
    t.string "icd9", limit: 6
    t.integer "order_num", default: 9999
    t.string "short_description", limit: 60
    t.text "description"
    t.boolean "is_active", default: true
    t.datetime "effective_date"
    t.datetime "expiration_date"
    t.boolean "is_common", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "group"
    t.boolean "is_header", default: true
    t.index ["icd"], name: "index_ref_icds_on_icd"
  end

  create_table "ref_lookups", id: :serial, force: :cascade do |t|
    t.string "keyprefix", limit: 32, null: false
    t.string "keyname", limit: 32
    t.text "keyvalue"
    t.integer "rank", limit: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "group"
    t.string "description"
    t.index ["keyprefix", "keyname"], name: "index_ref_lookups_on_keyprefix_and_keyname"
  end

  create_table "ref_place_of_services", id: :serial, force: :cascade do |t|
    t.string "code", limit: 2, null: false
    t.string "name", limit: 64, null: false
    t.string "description", limit: 4096
    t.datetime "effective_date"
    t.datetime "expiration_date"
    t.boolean "is_common", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_ref_place_of_services_on_code"
  end

  create_table "roles", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.integer "resource_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
  end

  create_table "usr_admins", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "practice_id"
    t.index ["practice_id"], name: "index_usr_admins_on_practice_id"
  end

  create_table "usr_licenses", id: :serial, force: :cascade do |t|
    t.integer "provider_id"
    t.integer "number"
    t.integer "state"
    t.datetime "expiration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "usr_providers", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "provider_code"
    t.string "external_provider_code", limit: 32
    t.string "position", limit: 256
    t.string "speciality_license_number", limit: 30
    t.string "medical_license_number", limit: 30
    t.string "tax_number", limit: 30
    t.string "dea_number", limit: 10
    t.string "dea_extension", limit: 20
    t.string "upin", limit: 24
    t.string "npi", limit: 10
    t.string "medicare_id", limit: 32
    t.string "medicaid_id", limit: 32
    t.string "hmo_id", limit: 32
    t.string "bank_account_number", limit: 32
    t.string "bank_routing_number", limit: 32
    t.boolean "can_prescribe", default: false
    t.text "xml_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0
    t.string "degree"
    t.integer "practice_id"
    t.string "ptan"
    t.boolean "tp_required", default: true
    t.integer "hp_account"
    t.boolean "claim_md_enabled", default: false
    t.boolean "hold_claims", default: false
    t.integer "linked_provider_id"
    t.index ["practice_id"], name: "index_usr_providers_on_practice_id"
    t.index ["user_id"], name: "index_usr_providers_on_user_id"
  end

  create_table "usr_reviewers", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "practice_id"
    t.integer "associated_patients", default: [], array: true
    t.integer "associated_facilities", default: [], array: true
    t.integer "associated_providers", default: [], array: true
    t.integer "reviewer_type", default: 0
    t.index ["associated_facilities"], name: "index_usr_reviewers_on_associated_facilities", using: :gin
    t.index ["associated_patients"], name: "index_usr_reviewers_on_associated_patients", using: :gin
    t.index ["associated_providers"], name: "index_usr_reviewers_on_associated_providers", using: :gin
    t.index ["practice_id"], name: "index_usr_reviewers_on_practice_id"
  end

  create_table "usr_users", id: :serial, force: :cascade do |t|
    t.string "last_name", limit: 64
    t.string "first_name", limit: 64
    t.string "middle_name", limit: 64
    t.string "title", limit: 16
    t.string "suffix", limit: 16
    t.string "initials", limit: 16
    t.string "ssn", limit: 16
    t.datetime "dob"
    t.string "gender", limit: 16
    t.string "position"
    t.string "address1", limit: 64
    t.string "address2", limit: 64
    t.string "city", limit: 64
    t.string "state", limit: 3
    t.string "zip", limit: 16
    t.string "home_phone", limit: 16
    t.string "work_phone", limit: 16
    t.string "fax", limit: 16
    t.string "cell", limit: 16
    t.string "pager", limit: 16
    t.string "alternate_phone", limit: 16
    t.string "email"
    t.string "authorization_token", limit: 40
    t.string "login_name", limit: 128
    t.text "xml_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.integer "meta_id"
    t.string "meta_type"
    t.integer "practice_id"
    t.integer "timezone", default: 0
    t.index ["authorization_token"], name: "index_usr_users_on_authorization_token"
    t.index ["email"], name: "index_usr_users_on_email", unique: true
    t.index ["login_name"], name: "index_usr_users_on_login_name"
    t.index ["meta_id", "meta_type"], name: "index_usr_users_on_meta_id_and_meta_type"
    t.index ["practice_id"], name: "index_usr_users_on_practice_id"
    t.index ["reset_password_token"], name: "index_usr_users_on_reset_password_token", unique: true
  end

  create_table "usr_users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["user_id", "role_id"], name: "index_usr_users_roles_on_user_id_and_role_id"
  end

end
