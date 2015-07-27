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

ActiveRecord::Schema.define(version: 4) do

  create_table "dashboards", force: :cascade do |t|
    t.integer  "domain_id"
    t.integer  "board_id"
    t.string   "name"
    t.datetime "last_synced"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "dashboards", ["domain_id"], name: "index_dashboards_on_domain_id"

  create_table "domains", force: :cascade do |t|
    t.string   "name"
    t.string   "domain"
    t.datetime "last_synced"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "issues", force: :cascade do |t|
    t.string   "key"
    t.string   "summary"
    t.string   "issue_type"
    t.integer  "dashboard_id"
    t.string   "epic_key"
    t.string   "epic_status"
    t.integer  "story_points"
    t.datetime "started"
    t.datetime "completed"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "issues", ["dashboard_id"], name: "index_issues_on_dashboard_id"
  add_index "issues", ["epic_key"], name: "index_issues_on_epic_key"

  create_table "wip_histories", force: :cascade do |t|
    t.date     "date"
    t.integer  "issue_id"
    t.string   "issue_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "wip_histories", ["issue_id"], name: "index_wip_histories_on_issue_id"
  add_index "wip_histories", ["issue_type"], name: "index_wip_histories_on_issue_type"

end
