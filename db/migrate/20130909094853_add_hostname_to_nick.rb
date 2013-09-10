class AddHostnameToNick < ActiveRecord::Migration
  def change
    add_column :nicks, :hostname_id, :int
  end
end
