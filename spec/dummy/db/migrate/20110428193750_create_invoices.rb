class CreateInvoices < ActiveRecord::Migration
  def self.up
    create_table :invoices do |t|
      t.date :value_date

      t.timestamps
    end
  end

  def self.down
    drop_table :invoices
  end
end
