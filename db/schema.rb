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

ActiveRecord::Schema[8.0].define(version: 2026_01_02_061612) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "generated_articles", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "title"
    t.text "content"
    t.string "status"
    t.text "gemini_prompt"
    t.datetime "published_at"
    t.string "wordpress_post_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_generated_articles_on_project_id"
  end

  create_table "plans", force: :cascade do |t|
    t.string "name"
    t.decimal "price"
    t.json "features"
    t.string "stripe_price_id"
    t.integer "max_projects"
    t.integer "max_articles"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active"
  end

  create_table "projects", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "url"
    t.text "wordpress_api_key"
    t.string "wordpress_username"
    t.string "name"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_projects_on_user_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "plan_id", null: false
    t.string "stripe_subscription_id"
    t.string "status"
    t.datetime "current_period_end"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["plan_id"], name: "index_subscriptions_on_plan_id"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.string "jti", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "stripe_customer_id"
    t.boolean "admin"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "generated_articles", "projects"
  add_foreign_key "projects", "users"
  add_foreign_key "subscriptions", "plans"
  add_foreign_key "subscriptions", "users"
end
