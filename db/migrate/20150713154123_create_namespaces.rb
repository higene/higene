class CreateNamespaces < ActiveRecord::Migration
  def change
    create_table :namespaces do |t|
      t.belongs_to :workspace, index: true
      t.string :name, null: false
    end
    add_index :namespaces, [:workspace_id, :name], unique: true
  end
end
