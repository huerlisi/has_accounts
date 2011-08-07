class SetupHasAccountsEngine < ActiveRecord::Migration
  def self.up
    create_table "account_types" do |t|
      t.string   "name",       :limit => 100
      t.string   "title",      :limit => 100
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "account_types", "name"

    create_table "accounts" do |t|
      t.string   "title",           :limit => 100
      t.integer  "parent_id"
      t.integer  "account_type_id"
      t.integer  "number"
      t.string   "code"
      t.string   "type"
      t.integer  "holder_id"
      t.string   "holder_type"
      t.integer  "bank_id"
      t.integer  "esr_id"
      t.integer  "pc_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "accounts", ["account_type_id"], :name => "index_accounts_on_account_type_id"
    add_index "accounts", ["bank_id"], :name => "index_accounts_on_bank_id"
    add_index "accounts", ["code"], :name => "index_accounts_on_code"
    add_index "accounts", ["holder_id", "holder_type"], :name => "index_accounts_on_holder_id_and_holder_type"
    add_index "accounts", ["type"], :name => "index_accounts_on_type"

    create_table "banks" do |t|
      t.integer  "vcard_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "banks", :vcard_id

    create_table "bookings" do |t|
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

    add_index "bookings", ["credit_account_id"], :name => "index_bookings_on_credit_account_id"
    add_index "bookings", ["debit_account_id"], :name => "index_bookings_on_debit_account_id"
    add_index "bookings", ["reference_id", "reference_type"], :name => "index_bookings_on_reference_id_and_reference_type"
    add_index "bookings", ["value_date"], :name => "index_bookings_on_value_date"
  end

  def self.down
    drop_table :account_types, :accounts, :banks, :bookings
  end
end
