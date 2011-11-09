class UseStringForAccountNumber < ActiveRecord::Migration
  def up
    change_column :bank_account, :number, :string
  end

  def down
    change_column :bank_account, :number, :integer
  end
end
