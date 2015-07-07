class AddGroupToUser < ActiveRecord::Migration
  def change
    add_column :users, :group_id, :int
  end
end
