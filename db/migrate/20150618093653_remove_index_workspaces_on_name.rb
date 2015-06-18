class RemoveIndexWorkspacesOnName < ActiveRecord::Migration
  def change
    remove_index :workspaces, :name
  end
end
