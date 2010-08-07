require 'test_helper'

class CollaborationsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:collaborations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create collaboration" do
    assert_difference('Collaboration.count') do
      post :create, :collaboration => { }
    end

    assert_redirected_to collaboration_path(assigns(:collaboration))
  end

  test "should show collaboration" do
    get :show, :id => collaborations(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => collaborations(:one).to_param
    assert_response :success
  end

  test "should update collaboration" do
    put :update, :id => collaborations(:one).to_param, :collaboration => { }
    assert_redirected_to collaboration_path(assigns(:collaboration))
  end

  test "should destroy collaboration" do
    assert_difference('Collaboration.count', -1) do
      delete :destroy, :id => collaborations(:one).to_param
    end

    assert_redirected_to collaborations_path
  end
end
