class ChangeBookingsAmountToUseDecimalScope < ActiveRecord::Migration
  def up
    change_column :bookings, :amount, :decimal, precision: 10, scale: 2
  end
end
