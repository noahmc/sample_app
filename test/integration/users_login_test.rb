require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "should display errors in flash on invalid login attempt for one request" do
    get login_path
    assert_template 'sessions/new'
    post login_path, session: { email: "michael@example.com", password: "foo" }
    assert_not is_logged_in?
    assert_not flash.empty?
    assert_template 'sessions/new'

    get root_path
    assert flash.empty?
  end

  test "should log a user in with correct credentials" do
    get login_path
    assert_template 'sessions/new'
    post login_path, session: { email: "michael@example.com", password: "password" }
    assert is_logged_in?
    assert flash.empty?
    follow_redirect!
    assert_template 'users/show'
  end

  test "login should change the links in the header followed by logout" do
    get login_path
    assert_select 'a[href=?]', user_path(@user), count: 0
    assert_select 'a[href=?]', logout_path, count: 0
    assert_select 'a[href=?]', login_path, count: 1
    post login_path, session: { email: "michael@example.com", password: "password" }
    assert is_logged_in?
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select 'a[href=?]', login_path, count: 0
    assert_select 'a[href=?]', logout_path, count: 1
    assert_select 'a[href=?]', user_path(@user)

    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url

    delete logout_path
    follow_redirect!
    assert_select 'a[href=?]', login_path, count: 1
    assert_select 'a[href=?]', logout_path, count: 0
    assert_select 'a[href=?]', user_path(@user), count: 0
  end

  test "login with remembering" do
    log_in_as( @user, remember_me: '1' )
    assert_not_nil cookies['remember_token']
  end

  test "login without remembering" do
    log_in_as( @user, remember_me: '0' )
    assert_nil cookies['remember_token']
  end
end
