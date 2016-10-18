class UseDecimalForInvoiceCode < ActiveRecord::Migration
  def up
    change_column :bookings, :code, :decimal, :scale => 0, :precision => 100
  end

  def down
    change_column :bookings, :code, :integer
  end
end
