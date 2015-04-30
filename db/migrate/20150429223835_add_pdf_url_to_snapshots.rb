class AddPdfUrlToSnapshots < ActiveRecord::Migration
  def change
    add_column :snapshots, :pdf_url, :string
  end
end
