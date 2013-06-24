class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :nick
      t.text :message
      t.time :saidAt

      t.timestamps
    end
  end
end
