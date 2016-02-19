require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  def setup
    @user = users(:michael)
    @user2 = users(:suzy)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should redirect edit when not logged in" do
    get :edit, id: @user

    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch :update, id: @user, user: {
      name: @user.name, email: @user.email
    }

    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect edit on information that does not belong to the user" do
    log_in_as(@user2)

    get :edit, id: @user

    assert_redirected_to root_url
  end

  test "should redirect update on information that does not belong to the user" do
    log_in_as(@user2)

    patch :update, id: @user, user: {
      name: @user.name, email: @user.email
    }

    assert_redirected_to root_url
  end

  test "should redirect index when not logged in" do
    get :index
    assert_redirected_to login_url
  end
end
