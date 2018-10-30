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

ActiveRecord::Schema.define(version: 20181025132648) do

  create_table "active_customers", force: :cascade do |t|
    t.string "custcode"
    t.string "rep"
    t.string "shipto"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "author_lists", force: :cascade do |t|
    t.string "partcode"
    t.string "dept"
    t.string "custcode"
    t.integer "turns"
    t.integer "seq"
    t.integer "priority"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "call_days", force: :cascade do |t|
    t.integer "call_list_id"
    t.string "callday"
    t.string "notes"
    t.string "isr"
    t.string "called"
    t.date "date_called"
    t.string "ordered"
    t.date "date_ordered"
    t.string "callback"
    t.date "callback_date"
    t.string "window"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "alt_contact"
  end

  create_table "call_lists", force: :cascade do |t|
    t.string "custcode"
    t.string "custname"
    t.string "contact_method"
    t.string "contact"
    t.string "phone"
    t.string "email"
    t.string "selling"
    t.string "main_phone"
    t.string "website"
    t.string "rep"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dont_sells", force: :cascade do |t|
    t.string "customer"
    t.string "part"
    t.date "dontcalls_start"
    t.date "dontcalls_end"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "isr_lists", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "on_specials", force: :cascade do |t|
    t.string "customer"
    t.string "part"
    t.date "onspecials_start"
    t.date "onspecials_end"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "override_call_lists", force: :cascade do |t|
    t.string "custcode"
    t.string "custname"
    t.string "contact_method"
    t.string "contact"
    t.string "phone"
    t.string "email"
    t.string "selling"
    t.string "main_phone"
    t.string "website"
    t.string "rep"
    t.date "override_start"
    t.date "override_end"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
