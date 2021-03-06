require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new( name: "Test User", email: "test@email.com",
                      password: "testtest", password_confirmation: "testtest" )
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = ''
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = ''
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.name = "a" * 144 + "email.com"
    assert_not @user.valid?
  end

  test "email validation should accept valid email addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid email addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                         foo@bar_baz.com foo@bar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email addresses should not be case-sensitive" do
    duplicate_user = @user.dup
    duplicate_user.email.upcase!
    @user.save
    assert_not duplicate_user.valid?
  end

  test "password should be present" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "deleting a user should delete its microposts" do
    @user.save
    @user.microposts.create!(content: "Lorem Ipsum")
    assert_difference "Micropost.count", -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    michael = users(:michael)
    suzy = users(:suzy)
    assert_not michael.following?(suzy)
    michael.follow(suzy)
    assert michael.following?(suzy)
    assert suzy.followers.include?(michael)
    michael.unfollow(suzy)
    assert_not michael.following?(suzy)
  end

  test "feed should have the user posts" do
    michael = users(:michael)

    michael.microposts.each { |micropost|
      assert michael.feed.include?(micropost)
    }
  end

  test "feed should not have posts from non-followed users" do
    michael = users(:michael)
    non_following = users(:user_2)

    non_following.microposts.each { |micropost|
      assert_not michael.feed.include?(micropost)
    }
  end

  test "feed should have posts from followed users" do
    michael = users(:michael)
    following = users(:user_1)

    following.microposts.each { |micropost|
      assert michael.feed.include?(micropost)
    }
  end
end
