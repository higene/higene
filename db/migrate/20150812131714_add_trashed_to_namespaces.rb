class AddTrashedToNamespaces < ActiveRecord::Migration
  def change
    add_column :namespaces, :trashed, :boolean, default: false
  end
end
