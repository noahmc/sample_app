require 'test_helper'

class UserSignupTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "User creation fail with invalid data" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, user: { name: "",
                               email: "user@invalid",
                               password: "foo",
                               password_confirmation: "bar" }
    end
    assert_template 'users/new'
  end

  test "User create success with valid data" do
    get signup_path
    assert_difference 'User.count' do
      post users_path, user: { name: "Test Account",
                               email: "test@email.com",
                               password: "testtest",
                               password_confirmation: "testtest" }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?

    # Try to log in before activation.
    log_in_as(user)
    assert_not is_logged_in?

    # Invalid activation link
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?

    # Invalid email
    get edit_account_activation_path(user.activation_token, email: "invalid email")
    assert_not is_logged_in?

    # Valid activation
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end
end
