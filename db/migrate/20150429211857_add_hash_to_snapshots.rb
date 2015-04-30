class AddHashToSnapshots < ActiveRecord::Migration
  def change
    add_column :snapshots, :hash, :string
  end
end
