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

ActiveRecord::Schema.define(version: 20180820122343) do

  create_table "call_lists", force: :cascade do |t|
    t.string "custcode"
    t.string "custname"
    t.string "contact_method"
    t.string "callday"
    t.text "notes"
    t.string "contact"
    t.string "phone"
    t.string "email"
    t.string "selling"
    t.string "main_phone"
    t.string "website"
    t.string "rep"
    t.string "isr"
    t.string "called"
    t.date "date_called"
    t.string "ordered"
    t.date "date_ordered"
    t.string "callback"
    t.date "callback_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "window"
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
