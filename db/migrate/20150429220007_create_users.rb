class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :coursera_id, null: false
      t.string :name, null: false
      t.string :locale
      t.string :timezone

      t.timestamps null: false
    end
  end
end
