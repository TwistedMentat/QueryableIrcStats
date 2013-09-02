class AddActionToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :action, :text
  end
end
