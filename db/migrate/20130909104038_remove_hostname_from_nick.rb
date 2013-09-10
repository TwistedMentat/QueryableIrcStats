class RemoveHostnameFromNick < ActiveRecord::Migration
  def up
    remove_column :nicks, :hostname
  end

  def down
  end
end
