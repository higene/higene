class AddTrashedToWorkspaces < ActiveRecord::Migration
  def change
    add_column :workspaces, :trashed, :boolean, default: false
  end
end
