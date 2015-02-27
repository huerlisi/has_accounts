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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(version: 20_131_105_212_025) do
  create_table 'account_types', force: true do |t|
    t.string 'name',       limit: 100
    t.string 'title',      limit: 100
    t.datetime 'created_at'
    t.datetime 'updated_at'
  end

  add_index 'account_types', ['name'], name: 'index_account_types_on_name'

  create_table 'accounts', force: true do |t|
    t.string 'title',           limit: 100
    t.integer 'parent_id'
    t.integer 'account_type_id'
    t.string 'number'
    t.string 'code'
    t.string 'type'
    t.integer 'holder_id'
    t.string 'holder_type'
    t.integer 'bank_id'
    t.integer 'esr_id'
    t.string 'pc_id'
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.string 'iban'
  end

  add_index 'accounts', ['account_type_id'], name: 'index_accounts_on_account_type_id'
  add_index 'accounts', ['bank_id'], name: 'index_accounts_on_bank_id'
  add_index 'accounts', ['code'], name: 'index_accounts_on_code'
  add_index 'accounts', %w(holder_id holder_type), name: 'index_accounts_on_holder_id_and_holder_type'
  add_index 'accounts', ['parent_id'], name: 'index_accounts_on_parent_id'
  add_index 'accounts', ['type'], name: 'index_accounts_on_type'

  create_table 'booking_templates', force: true do |t|
    t.string 'title'
    t.string 'amount'
    t.integer 'credit_account_id'
    t.integer 'debit_account_id'
    t.text 'comments'
    t.datetime 'created_at',              null: false
    t.datetime 'updated_at',              null: false
    t.string 'code'
    t.string 'matcher'
    t.string 'amount_relates_to'
    t.string 'type'
    t.string 'charge_rate_code'
    t.string 'salary_declaration_code'
    t.integer 'position'
  end

  create_table 'bookings', force: true do |t|
    t.string 'title',             limit: 100
    t.decimal 'amount',                            precision: 10, scale: 2
    t.integer 'credit_account_id'
    t.integer 'debit_account_id'
    t.date 'value_date'
    t.text 'comments',          limit: 1000,                                default: ''
    t.string 'scan'
    t.string 'debit_currency',                                                   default: 'CHF'
    t.string 'credit_currency',                                                  default: 'CHF'
    t.float 'exchange_rate',                                                    default: 1.0
    t.datetime 'created_at'
    t.datetime 'updated_at'
    t.integer 'reference_id'
    t.string 'reference_type'
    t.integer 'template_id'
    t.string 'template_type'
  end

  add_index 'bookings', ['credit_account_id'], name: 'index_bookings_on_credit_account_id'
  add_index 'bookings', ['debit_account_id'], name: 'index_bookings_on_debit_account_id'
  add_index 'bookings', %w(reference_id reference_type), name: 'index_bookings_on_reference_id_and_reference_type'
  add_index 'bookings', %w(template_id template_type), name: 'index_bookings_on_template_id_and_template_type'
  add_index 'bookings', ['value_date'], name: 'index_bookings_on_value_date'

  create_table 'invoices', force: true do |t|
    t.date 'value_date'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'people', force: true do |t|
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'swift'
    t.string 'clearing'
  end
end
