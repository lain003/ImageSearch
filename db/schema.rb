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

ActiveRecord::Schema.define(version: 20180905180150) do

  create_table "edited_gifs", force: :cascade do |t|
    t.string "file_name"
    t.integer "meta_frame_id"
    t.integer "start_frame"
    t.integer "end_frame"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["meta_frame_id"], name: "index_edited_gifs_on_meta_frame_id"
  end

  create_table "meta_frames", force: :cascade do |t|
    t.integer "movie_id"
    t.float "start_sec", null: false
    t.float "end_sec", null: false
    t.string "text", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "index_meta_frames_on_movie_id"
    t.index ["start_sec"], name: "index_meta_frames_on_start_sec"
  end

  create_table "movies", force: :cascade do |t|
    t.integer "season_id"
    t.integer "ep_num"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ep_num"], name: "index_movies_on_ep_num"
    t.index ["id", "ep_num"], name: "index_movies_on_id_and_ep_num", unique: true
    t.index ["season_id"], name: "index_movies_on_season_id"
  end

  create_table "seasons", force: :cascade do |t|
    t.integer "siry_id"
    t.integer "serial"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["serial"], name: "index_seasons_on_serial"
    t.index ["siry_id"], name: "index_seasons_on_siry_id"
  end

  create_table "siries", force: :cascade do |t|
    t.string "name"
    t.string "identifier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["identifier"], name: "index_siries_on_identifier", unique: true
    t.index ["name"], name: "index_siries_on_name", unique: true
  end

end
