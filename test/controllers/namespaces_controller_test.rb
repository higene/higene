require 'test_helper'

class NamespacesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    @user = users(:bill)
    @workspace = workspaces(:w1)
    @workspace_w2 = workspaces(:w2)
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
    assert_not assigns(:namespace).trashed
  end

  test "should post create and strip namespace name" do
    sign_in @user
    post :create, workspace_id: @workspace, name: " hs "
    assert_response :success
    assert_not_nil assigns(:namespace)
    assert_not assigns(:namespace).trashed
    assert_equal "hs", assigns(:namespace).name
  end

  test "should not post create when duplicated namespace names" do
    sign_in @user
    post :create, workspace_id: @workspace, name: @namespace.name
    assert_response :bad_request
  end

  test "should not post create when empty namespace name" do
    sign_in @user
    post :create, workspace_id: @workspace, name: ""
    assert_response :bad_request
  end

  test "should not post create when blank namespace name" do
    sign_in @user
    post :create, workspace_id: @workspace, name: " "
    assert_response :bad_request
  end

  test "should not post create for invalid workspace id" do
    sign_in @user
    post :create, workspace_id: "invalid workspace id",
                  name: @namespace.name
    assert_response :bad_request
  end

  test "should not post create for unauthorized workspace id" do
    sign_in @user
    post :create, workspace_id: @workspace_w2,
                  name: @namespace.name
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
    assert_not assigns(:namespace).trashed
  end

  test "should not get show for invalid workspace id" do
    sign_in @user
    get :show, workspace_id: "invalid worksapce id", id: @namespace
    assert_response :bad_request
  end

  test "should not get show for unauthorized workspace id" do
    sign_in @user
    get :show, workspace_id: @workspace_w2, id: @namespace
    assert_response :bad_request
  end

  test "should not get show for invalid namespace id" do
    sign_in @user
    get :show, workspace_id: @workspace, id: "invalid namespace id"
    assert_response :bad_request
  end

  test "should redirect update when not logged in" do
    put :update, workspace_id: @workspace,
                 id: @namespace,
                 name: "another name"
    assert_redirected_to new_user_session_path
  end

  test "should put update" do
    sign_in @user
    put :update, workspace_id: @workspace,
                 id: @namespace,
                 name: "another name"
    assert_response :success
    assert_not_nil assigns(:namespace)
  end

  test "should not put update for invalid workspace id" do
    sign_in @user
    put :update, workspace_id: "invalid workspace id",
                 id: @namespace,
                 name: "another name"
    assert_response :bad_request
  end

  test "should not put update for unauthorized workspace id" do
    sign_in @user
    put :update, workspace_id: @workspace_w2,
                 id: @namespace,
                 name: "another name"
    assert_response :bad_request
  end

  test "should not put update for invalid namespace id" do
    sign_in @user
    put :update, workspace_id: @workspace,
                 id: "invalid namespace id",
                 name: "another name"
    assert_response :bad_request
  end

  test "should put update when namespace name does not change" do
    sign_in @user
    put :update, workspace_id: @workspace,
                 id: @namespace,
                 name: @namespace.name
    assert_response :success
    assert_not_nil assigns(:namespace)
  end

  test "should not put update when default namespace" do
    sign_in @user
    put :update, workspace_id: @workspace,
                 id: @default_namespace,
                 name: "ss"
    assert_response :bad_request
  end

  test "should not put update when namespace name already exists" do
    sign_in @user
    put :update, workspace_id: @workspace,
                 id: @namespace,
                 name: "fly"
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
    assert assigns(:namespace).trashed
  end

  test "should not delete destroy for invalid workspace id" do
    sign_in @user
    delete :destroy, workspace_id: "invalid workspace id",
                     id: @namespace
    assert_response :bad_request
  end

  test "should not delete destroy for unauthorized workspace id" do
    sign_in @user
    delete :destroy, workspace_id: @workspace_w2,
                     id: @namespace
    assert_response :bad_request
  end

  test "should not delete destroy for invalid namespace id" do
    sign_in @user
    delete :destroy, workspace_id: @workspace,
                     id: "invalid namespace id"
    assert_response :bad_request
  end

  test "should not delete destroy for default namespace name" do
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
    assert assigns(:namespaces).all? { |x| !x.trashed }
    assert_equal 2, assigns(:namespaces).length
  end
end
