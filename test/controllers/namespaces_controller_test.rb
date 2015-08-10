require 'test_helper'

class NamespacesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    @user = users(:bill)
    @workspace = workspaces(:w1)
    @default_namespace = namespaces(:root)
    @namespace = namespaces(:human)
  end

  test "should redirect create when not logged in" do
    post :create, workspace_id: @workspace, name: "hs"
    assert_redirected_to new_user_session_path
  end

  test "should post create" do
    sign_in @user
    post :create, workspace_id: @workspace, name: "hs"
    assert_response :success
    assert_not_nil assigns(:namespace)
  end

  test "should redirect create when duplicated namespaces" do
    sign_in @user
    post :create, workspace_id: @workspace, name: @namespace.name
    assert_response :bad_request
  end

  test "should redirect show when not logged in" do
    get :show, workspace_id: @workspace, id: @namespace
    assert_redirected_to new_user_session_path
  end

  test "should get show" do
    sign_in @user
    get :show, workspace_id: @workspace, id: @namespace
    assert_response :success
    assert_not_nil assigns(:namespace)
  end

  test "should redirect update when not logged in" do
    put :update, workspace_id: @workspace, id: @namespace, name: "ss"
    assert_redirected_to new_user_session_path
  end

  test "should put update" do
    sign_in @user
    put :update, workspace_id: @workspace, id: @namespace, name: "ss"
    assert_response :success
    assert_not_nil assigns(:namespace)
  end

  test "should not put update when default namespace" do
    sign_in @user
    put :update, workspace_id: @workspace, id: @default_namespace, name: "ss"
    assert_response :bad_request
  end

  test "should redirect destroy when not logged in" do
    delete :destroy, workspace_id: @workspace, id: @namespace
    assert_redirected_to new_user_session_path
  end

  test "should delete destroy" do
    sign_in @user
    delete :destroy, workspace_id: @workspace, id: @namespace
    assert_response :success
    assert_not_nil assigns(:namespace)
  end

  test "should not delete destroy when default namespace" do
    sign_in @user
    delete :destroy, workspace_id: @workspace, id: @default_namespace
    assert_response :bad_request
  end

  test "should redirect index when not logged in" do
    get :index, workspace_id: @workspace
    assert_redirected_to new_user_session_path
  end

  test "should get index" do
    sign_in @user
    get :index, workspace_id: @workspace
    assert_response :success
    assert_not_nil assigns(:namespaces)
  end
end
