class CreateSnapshots < ActiveRecord::Migration
  def change
    create_table :snapshots do |t|
      t.string :url, null: false
      
      t.timestamps null: false
    end
  end
end
