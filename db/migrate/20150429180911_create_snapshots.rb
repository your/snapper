class CreateSnapshots < ActiveRecord::Migration
  def change
    create_table :snapshots do |t|
      t.string :url, null: false
      t.string :generated_hash
      t.integer :user_id, null: false
      t.integer :views, default: 0
      t.integer :ready, default: 0
      t.integer :duration
      t.string :error
      
      t.timestamps null: false
    end
  end
end
