require 'test_helper'

class WorkspaceTest < ActiveSupport::TestCase
  test "should save workspace" do
    member = Member.new role: "owner", user: users(:bill)
    workspace = Workspace.new name: "new workspace",
                              members: [member]
    assert workspace.save
  end

  test "should create default namespace after saving workspace" do
    member = Member.new role: "owner", user: users(:bill)
    workspace = Workspace.new name: "new workspace",
                              members: [member]
    workspace.save
    assert_not_nil workspace.namespaces
    assert_equal workspace.namespaces.length, 1
    assert_equal workspace.namespaces.first.name, "root"
  end

  test "should not save workspace when name is nil" do
    member = Member.new(role: "owner", user: users(:bill))
    workspace = Workspace.new members: [member]
    assert_not workspace.save
  end

  test "should not save workspace when member is nil" do
    workspace = Workspace.new name: "new workspace"
    assert_not workspace.save
  end

  test "should not save workspace when duplicated workspace names for a user" do
    member = Member.new(role: "owner", user: users(:bill))
    workspace = Workspace.new name: "workspace 1",
                              members: [member]
    assert_not workspace.save
  end

  test "should update name" do
    workspace = workspaces(:w1)
    assert workspace.update name: "another name"
  end

  test "should not update name if name already exists" do
    workspace = workspaces(:w1)
    assert_not workspace.update name: "workspace 3"
  end

  test "should update description" do
    workspace = workspaces(:w1)
    assert workspace.update description: "another description"
  end

  test "should update members" do
    member = Member.new role: "editor",
                        user: users(:hunter)
    workspace = workspaces(:w1)
    workspace.members << member
    assert workspace.save
  end

  test "should not update members when duplicated owner" do
    member = Member.new role: "owner",
                        user: users(:hunter)
    workspace = workspaces(:w1)
    workspace.members << member
    assert_not workspace.save
  end
end
