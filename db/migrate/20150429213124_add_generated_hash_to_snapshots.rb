class AddGeneratedHashToSnapshots < ActiveRecord::Migration
  def change
    add_column :snapshots, :generated_hash, :string
  end
end
