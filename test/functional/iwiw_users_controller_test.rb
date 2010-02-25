require 'test_helper'

class IwiwUsersControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:iwiw_users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create iwiw_user" do
    assert_difference('IwiwUser.count') do
      post :create, :iwiw_user => { }
    end

    assert_redirected_to iwiw_user_path(assigns(:iwiw_user))
  end

  test "should show iwiw_user" do
    get :show, :id => iwiw_users(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => iwiw_users(:one).to_param
    assert_response :success
  end

  test "should update iwiw_user" do
    put :update, :id => iwiw_users(:one).to_param, :iwiw_user => { }
    assert_redirected_to iwiw_user_path(assigns(:iwiw_user))
  end

  test "should destroy iwiw_user" do
    assert_difference('IwiwUser.count', -1) do
      delete :destroy, :id => iwiw_users(:one).to_param
    end

    assert_redirected_to iwiw_users_path
  end
end
