require 'test_helper'

class MemberTest < ActiveSupport::TestCase
  def setup
    @user = users(:bill)
    @workspace = Workspace.new name: "new workspace"
  end

  test "should save when owner role" do
    member = Member.new workspace: @workspace,
                        user: @user,
                        role: "owner"
    assert member.save
  end

  test "should save when editor role" do
    member = Member.new workspace: @workspace,
                        user: @user,
                        role: "editor"
    assert member.save
  end

  test "should save when viewer role" do
    member = Member.new workspace: @workspace,
                        user: @user,
                        role: "viewer"
    assert member.save
  end

  test "should not save when invalid role" do
    member = Member.new workspace: @workspace,
                        user: @user,
                        role: "admin"
    assert_not member.save
  end

  test "should not save when role is not present" do
    member = Member.new workspace: @workspace,
                        user: @user
    assert_not member.save
  end
end
