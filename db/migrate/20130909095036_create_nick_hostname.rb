class CreateNickHostname < ActiveRecord::Migration
  def up
    create_table :nick_hostnames do |t|
      t.integer :nick_id, null: false
      t.integer :hostname_id, null: false
    end
  end

  def down
  end
end
