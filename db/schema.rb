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

ActiveRecord::Schema[8.1].define(version: 2026_05_04_000012) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "admin_replies", force: :cascade do |t|
    t.bigint "answer_id", null: false
    t.datetime "created_at", null: false
    t.text "reply_text", null: false
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["answer_id", "user_id"], name: "index_admin_replies_on_answer_id_and_user_id"
    t.index ["answer_id"], name: "index_admin_replies_on_answer_id"
    t.index ["user_id"], name: "index_admin_replies_on_user_id"
  end

  create_table "answer_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.bigint "question_id", null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_answer_tokens_on_question_id"
    t.index ["token"], name: "index_answer_tokens_on_token", unique: true
  end

  create_table "answers", force: :cascade do |t|
    t.text "body"
    t.bigint "choice_id"
    t.bigint "company_id"
    t.datetime "created_at", null: false
    t.bigint "question_id", null: false
    t.string "session_id"
    t.string "session_id_hash", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["choice_id"], name: "index_answers_on_choice_id"
    t.index ["company_id"], name: "index_answers_on_company_id"
    t.index ["question_id", "session_id_hash"], name: "index_answers_on_question_and_session_hash", unique: true
    t.index ["question_id"], name: "index_answers_on_question_id"
    t.index ["session_id_hash"], name: "index_answers_on_session_id_hash"
    t.index ["user_id"], name: "index_answers_on_user_id"
  end

  create_table "choices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "label", null: false
    t.bigint "question_id", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id", "label"], name: "index_choices_on_question_id_and_label", unique: true
    t.index ["question_id"], name: "index_choices_on_question_id"
  end

  create_table "companies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "member_count", default: 0
    t.string "name", null: false
    t.bigint "owner_id"
    t.integer "question_count", default: 0
    t.datetime "updated_at", null: false
    t.integer "visibility", default: 0
    t.index ["name"], name: "index_companies_on_name"
    t.index ["owner_id"], name: "index_companies_on_owner_id"
  end

  create_table "company_members", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.integer "role", default: 2
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["company_id", "user_id"], name: "index_company_members_on_company_id_and_user_id", unique: true
    t.index ["company_id"], name: "index_company_members_on_company_id"
    t.index ["user_id"], name: "index_company_members_on_user_id"
  end

  create_table "departments", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.integer "member_count", default: 0
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "name"], name: "index_departments_on_company_id_and_name", unique: true
    t.index ["company_id"], name: "index_departments_on_company_id"
  end

  create_table "invite_tokens", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.bigint "creator_id"
    t.datetime "expires_at"
    t.integer "status", default: 0
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.datetime "used_at"
    t.integer "used_by_id"
    t.index ["company_id", "status"], name: "index_invite_tokens_on_company_id_and_status"
    t.index ["company_id"], name: "index_invite_tokens_on_company_id"
    t.index ["creator_id"], name: "index_invite_tokens_on_creator_id"
    t.index ["token"], name: "index_invite_tokens_on_token", unique: true
  end

  create_table "question_analyses", force: :cascade do |t|
    t.datetime "analyzed_at"
    t.float "average_rating", default: 0.0
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.text "keywords"
    t.bigint "question_id", null: false
    t.text "sentiment_summary"
    t.integer "total_responses", default: 0
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_question_analyses_on_company_id"
    t.index ["question_id", "company_id"], name: "index_question_analyses_on_question_id_and_company_id", unique: true
    t.index ["question_id"], name: "index_question_analyses_on_question_id"
  end

  create_table "question_targets", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "question_id", null: false
    t.integer "target_type", default: 0
    t.integer "targetable_id", null: false
    t.string "targetable_type", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id", "targetable_type", "targetable_id"], name: "index_question_targets_on_question_and_targetable", unique: true
    t.index ["question_id"], name: "index_question_targets_on_question_id"
  end

  create_table "question_templates", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.text "questions_data"
    t.integer "template_type", default: 0
    t.datetime "updated_at", null: false
    t.index ["company_id", "name"], name: "index_question_templates_on_company_id_and_name", unique: true
    t.index ["company_id"], name: "index_question_templates_on_company_id"
  end

  create_table "questions", force: :cascade do |t|
    t.text "body"
    t.bigint "company_id"
    t.datetime "created_at", null: false
    t.datetime "deadline"
    t.bigint "department_id"
    t.string "question_type"
    t.integer "response_count", default: 0
    t.string "status"
    t.string "title"
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_questions_on_company_id"
    t.index ["department_id"], name: "index_questions_on_department_id"
  end

  create_table "recurring_schedules", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.integer "day_of_month"
    t.integer "frequency", default: 0
    t.datetime "last_run_at"
    t.string "name", null: false
    t.datetime "next_scheduled_at"
    t.bigint "question_id"
    t.integer "status", default: 0
    t.datetime "updated_at", null: false
    t.index ["company_id", "frequency"], name: "index_recurring_schedules_on_company_id_and_frequency"
    t.index ["company_id"], name: "index_recurring_schedules_on_company_id"
    t.index ["question_id"], name: "index_recurring_schedules_on_question_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name"
    t.boolean "notification_enabled", default: true
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "admin_replies", "answers"
  add_foreign_key "admin_replies", "users"
  add_foreign_key "answer_tokens", "questions"
  add_foreign_key "answers", "choices"
  add_foreign_key "answers", "companies"
  add_foreign_key "answers", "questions"
  add_foreign_key "answers", "users"
  add_foreign_key "choices", "questions"
  add_foreign_key "companies", "users", column: "owner_id"
  add_foreign_key "company_members", "companies"
  add_foreign_key "company_members", "users"
  add_foreign_key "departments", "companies"
  add_foreign_key "invite_tokens", "companies"
  add_foreign_key "invite_tokens", "users", column: "creator_id"
  add_foreign_key "invite_tokens", "users", column: "used_by_id"
  add_foreign_key "question_analyses", "companies"
  add_foreign_key "question_analyses", "questions"
  add_foreign_key "question_targets", "questions"
  add_foreign_key "question_templates", "companies"
  add_foreign_key "questions", "companies"
  add_foreign_key "questions", "departments"
  add_foreign_key "recurring_schedules", "companies"
  add_foreign_key "recurring_schedules", "questions"
end
