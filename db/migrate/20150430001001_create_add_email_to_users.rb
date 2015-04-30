class CreateAddEmailToUsers < ActiveRecord::Migration
  def change
    create_table :add_email_to_users do |t|
      t.string :email

      t.timestamps null: false
    end
  end
end
