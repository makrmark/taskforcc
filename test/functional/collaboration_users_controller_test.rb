require 'test_helper'

class CollaborationUsersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:collaboration_users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create collaboration_user" do
    assert_difference('CollaborationUser.count') do
      post :create, :collaboration_user => { }
    end

    assert_redirected_to collaboration_user_path(assigns(:collaboration_user))
  end

  test "should show collaboration_user" do
    get :show, :id => collaboration_users(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => collaboration_users(:one).to_param
    assert_response :success
  end

  test "should update collaboration_user" do
    put :update, :id => collaboration_users(:one).to_param, :collaboration_user => { }
    assert_redirected_to collaboration_user_path(assigns(:collaboration_user))
  end

  test "should destroy collaboration_user" do
    assert_difference('CollaborationUser.count', -1) do
      delete :destroy, :id => collaboration_users(:one).to_param
    end

    assert_redirected_to collaboration_users_path
  end
end
