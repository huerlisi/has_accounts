class ChangeBookingsAmountToUseDecimalScope < ActiveRecord::Migration
  def up
    change_column :bookings, :amount, :decimal, :precision => 10, :scope => 2
  end
end
