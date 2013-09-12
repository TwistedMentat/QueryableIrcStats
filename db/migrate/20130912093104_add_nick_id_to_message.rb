class AddNickIdToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :nick_id, :int
    remove_column :messages, :nick
  end
end
