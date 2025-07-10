require "test_helper"

class UserTest < ActiveSupport::TestCase

  # TEST 1
  test "should be valid with valid attributes" do
    @user = User.new(email: "test@example.com", password: Devise::Encryptor.digest(User, 'password'), name: "name")
    assert @user.valid?
  end
end
