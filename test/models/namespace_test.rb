require 'test_helper'

class NamespaceTest < ActiveSupport::TestCase
  test "should save if name is default name and does not exists" do
    namespace = Namespace.new name: "root", workspace: workspaces(:w2)
    assert namespace.save
  end

  test "should save if name is not default name" do
    namespace = Namespace.new name: "new_namespace", workspace: workspaces(:w1)
    assert namespace.save
  end

  test "should not save if name already exists" do
    namespace = Namespace.new name: "human", workspace: workspaces(:w1)
    assert_not namespace.save
  end

  test "should update if name is not default name" do
    assert namespaces(:human).update name: "updated_namespace",
                                     workspace: workspaces(:w1)
  end

  test "should not update if name is default name" do
    assert_not namespaces(:root).update name: "updated_namespace",
                                        workspace: workspaces(:w1)
  end
end
