class ChangeSaidAtFromTimeToDateTime < ActiveRecord::Migration
  change_table :messages do |t|
    t.remove :saidAt
    t.datetime :said_at
  end
end
