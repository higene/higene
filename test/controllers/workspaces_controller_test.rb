require 'test_helper'

class WorkspacesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    @user = users(:bill)
    @user_editor = users(:jeffrey)
    @user_viewer = users(:tom)
    @user_other = users(:hunter)
    @workspace = workspaces(:w1)
    @workspace_w2 = workspaces(:w2)
  end

  test "should redirect create when not logged in" do
    post :create, name: "new workspace",
                  description: "this is a new workspace"
    assert_redirected_to new_user_session_path
  end

  test "should post create" do
    sign_in @user
    post :create, name: "new workspace",
                  description: "this is a new workspace"
    assert_response :success
    assert_not_nil assigns(:workspace)
    assert_not assigns(:workspace).trashed
  end

  test "should not post create when workspace name already existed" do
    sign_in @user
    post :create, name: "workspace 1",
                  description: "this is w1"
    assert_response :bad_request
  end

  test "should not post create when missing workspace name parameter" do
    sign_in @user
    post :create, description: "this is a new workspace"
    assert_response :bad_request
  end

  test "should redirect show when not logged in" do
    get :show, id: @workspace
    assert_redirected_to new_user_session_path
  end

  test "should get show" do
    sign_in @user
    get :show, id: @workspace
    assert_response :success
    assert_not_nil assigns(:workspace)
  end

  test "should not get show for invalid workspace id" do
    sign_in @user
    get :show, id: "invalid workspace id"
    assert_response :bad_request
  end

  test "should not get show for unauthorized workspace" do
    sign_in @user
    get :show, id: @workspace_w2
    assert_response :bad_request
  end

  test "should redirect update when not logged in" do
    put :update, id: @workspace,
                 name: "another name",
                 description: "a"
    assert_redirected_to new_user_session_path
  end

  test "should put update" do
    sign_in @user
    put :update, id: @workspace,
                 name: "another name",
                 description: "a"
    assert_response :success
  end

  test "should put update when workspace name does not change" do
    sign_in @user
    put :update, id: @workspace,
                 name: @workspace.name,
                 description: "a"
    assert_response :success
  end

  test "should put update when user role is editor" do
    sign_in @user_editor
    put :update, id: @workspace,
                 name: "another name",
                 description: "a"
    assert_response :success
  end

  test "should not put update when user role is not owner or editor" do
    sign_in @user_viewer
    put :update, id: @workspace,
                 name: "another name",
                 description: "a"
    assert_response :bad_request
  end

  test "should not put update for invalid user" do
    sign_in @user_other
    put :update, id: @workspace,
                 name: "another name",
                 description: "a"
    assert_response :bad_request
  end

  test "should not put update for invalid workspace id" do
    sign_in @user
    put :update, id: "invalid workspace id",
                 name: "another name",
                 description: "a"
    assert_response :bad_request
  end

  test "should not put update for unauthorized workspace" do
    sign_in @user
    put :update, id: @workspace_w2,
                 name: "another name",
                 description: "a"
    assert_response :bad_request
  end

  test "should not put update when workspace name already existed" do
    sign_in @user
    put :update, id: @workspace,
                 name: "workspace 3",
                 description: "a"
    assert_response :bad_request
  end

  test "should redirect destory when not logged in" do
    delete :destroy, id: @workspace
    assert_redirected_to new_user_session_path
  end

  test "should delete destroy" do
    sign_in @user
    delete :destroy, id: @workspace
    assert_response :success
    assert_not_nil assigns(:workspace)
    assert assigns(:workspace).trashed
  end

  test "should not delete destroy for invalid workspace id" do
    sign_in @user
    delete :destroy, id: "invalid workspace id"
    assert_response :bad_request
  end

  test "should not delete destroy when user role is editor" do
    sign_in @user_editor
    delete :destroy, id: @workspace
    assert_response :bad_request
  end

  test "should not delete destroy when user role is viewer" do
    sign_in @user_viewer
    delete :destroy, id: @workspace
    assert_response :bad_request
  end

  test "should not delete destroy for unauthorized workspace" do
    sign_in @user
    delete :destroy, id: @workspace_w2
    assert_response :bad_request
  end

  test "should redirect new when not logged in" do
    get :new
    assert_redirected_to new_user_session_path
  end

  test "should redirect edit when not logged in" do
    get :edit, id: @workspace
    assert_redirected_to new_user_session_path
  end
end
