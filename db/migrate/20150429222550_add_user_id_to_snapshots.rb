class AddUserIdToSnapshots < ActiveRecord::Migration
  def change
    add_column :snapshots, :user_id, :integer
  end
end
