class CreateWorkspaces < ActiveRecord::Migration
  def change
    create_table :workspaces do |t|
      t.string :name, null: false
      t.text :description
      t.timestamps null: false
    end
    add_index :workspaces, :name, unique: true
  end
end
