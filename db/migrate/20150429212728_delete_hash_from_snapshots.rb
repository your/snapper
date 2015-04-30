class DeleteHashFromSnapshots < ActiveRecord::Migration
  def change
    remove_column :snapshots, :hash
  end
end
