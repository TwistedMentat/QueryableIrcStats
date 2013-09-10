class RemoveHostnameIdFromNicks < ActiveRecord::Migration
  def up
    remove_column :nicks, :hostname_id
  end

  def down
  end
end
