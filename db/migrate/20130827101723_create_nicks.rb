class CreateNicks < ActiveRecord::Migration
  def change
    create_table :nicks do |t|
      t.text :name
      t.text :hostname
      t.text :username

      t.timestamps
    end
  end
end
