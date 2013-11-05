class AddIndexOnAccountParentId < ActiveRecord::Migration
  def up
    add_index :accounts, :parent_id
  end

  def down
    remove_index :accounts, :parent_id
  end
end
