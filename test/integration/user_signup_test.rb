require 'test_helper'

class UserSignupTest < ActionDispatch::IntegrationTest
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
      post_via_redirect users_path, user: { name: "Test Account",
                                            email: "test@email.com",
                                            password: "testtest",
                                            password_confirmation: "testtest" }
    end
    assert_template 'users/show'
  end
end
