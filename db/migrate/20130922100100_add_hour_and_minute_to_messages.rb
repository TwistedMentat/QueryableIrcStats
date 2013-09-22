class AddHourAndMinuteToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :hour, :integer
    add_column :messages, :minute, :integer
  end
end
