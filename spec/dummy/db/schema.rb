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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110428205609) do

  create_table "account_types", :force => true do |t|
    t.string   "name",       :limit => 100
    t.string   "title",      :limit => 100
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "accounts", :force => true do |t|
    t.string   "title",           :limit => 100
    t.integer  "parent_id"
    t.integer  "account_type_id"
    t.integer  "number"
    t.string   "code"
    t.integer  "type"
    t.integer  "holder_id"
    t.string   "holder_type"
    t.integer  "bank_id"
    t.integer  "esr_id"
    t.integer  "pc_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "accounts", ["bank_id"], :name => "index_accounts_on_bank_id"
  add_index "accounts", ["code"], :name => "index_accounts_on_code"
  add_index "accounts", ["holder_id", "holder_type"], :name => "index_accounts_on_holder_id_and_holder_type"
  add_index "accounts", ["type"], :name => "index_accounts_on_type"

  create_table "banks", :force => true do |t|
    t.integer  "vcard_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bookings", :force => true do |t|
    t.string   "title",             :limit => 100
    t.decimal  "amount"
    t.integer  "credit_account_id"
    t.integer  "debit_account_id"
    t.date     "value_date"
    t.text     "comments",          :limit => 1000, :default => ""
    t.string   "scan"
    t.string   "debit_currency",                    :default => "CHF"
    t.string   "credit_currency",                   :default => "CHF"
    t.float    "exchange_rate",                     :default => 1.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reference_id"
    t.string   "reference_type"
  end

  create_table "invoices", :force => true do |t|
    t.date     "value_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
