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

ActiveRecord::Schema.define(version: 20160104043511) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "games", force: :cascade do |t|
    t.string   "status",            default: "pending"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "current_player_id"
    t.integer  "winner_id"
    t.integer  "loser_id"
  end

  create_table "player_game_states", force: :cascade do |t|
    t.integer  "game_id"
    t.integer  "player_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.text     "battle_grid"
    t.text     "tracking_grid"
  end

  add_index "player_game_states", ["game_id"], name: "index_player_game_states_on_game_id", using: :btree
  add_index "player_game_states", ["player_id"], name: "index_player_game_states_on_player_id", using: :btree

  create_table "players", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "players", ["email"], name: "index_players_on_email", unique: true, using: :btree
  add_index "players", ["reset_password_token"], name: "index_players_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "player_game_states", "games"
  add_foreign_key "player_game_states", "players"
end
