require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    post users_path, user: { name: "Test Account",
                             email: "test@email.com",
                             password: "testtest",
                             password_confirmation: "testtest" }
  end

  test "should display errors in flash on invalid login attempt for one request" do
    get login_path
    assert_template 'sessions/new'
    post login_path, session: { email: "test@email.com", password: "foo" }
    assert_not flash.empty?
    assert_template 'sessions/new'

    get root_path
    assert flash.empty?
  end

  test "should log a user in with correct credentials" do
    get login_path
    assert_template 'sessions/new'
    post login_path, session: { email: "test@email.com", password: "testtest" }
    assert flash.empty?
    assert_template 'users/show'
  end
end
