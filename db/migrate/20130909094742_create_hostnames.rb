class CreateHostnames < ActiveRecord::Migration
  def change
    create_table :hostnames do |t|
      t.string :domain_name

      t.timestamps
    end
  end
end
