class AddProcessingFlagsToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :processed, :boolean
    add_column :messages, :duplicate, :boolean
  end
end
