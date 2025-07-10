require "test_helper"

class CourseTest < ActiveSupport::TestCase

  # TEST 1
  test "should not create a course without a title" do
    @user = User.create(email: "test@example.com", password: Devise::Encryptor.digest(User, 'password'), name: "name")
    @course = Course.new(title: nil, description: "This is the description of the course", course_types: ['Ciencias'], 
                         user: @user)
    result = @course.save
    assert_not result
  end

  # TEST 2
  test "should not create a course without a description" do
    @user = User.create(email: "test@example.com", password: Devise::Encryptor.digest(User, 'password'), name: "name")
    @course = Course.new(title: "Title", description: nil, course_types: ['Ciencias'], user: @user)
    result = @course.save
    assert_not result
  end

  # TEST 3
  test "should not create a course with an empty title" do
    @user = User.create(email: "test@example.com", password: Devise::Encryptor.digest(User, 'password'), name: "name")
    @course = Course.new(title: "", description: "This is the description of the course", course_types: ['Ciencias'], 
                         user: @user)
    result = @course.save
    assert_not result
  end

  # TEST 4
  test "should not create a post with an empty description" do
    @user = User.create(email: "test@example.com", password: Devise::Encryptor.digest(User, 'password'), name: "name")
    @course = Course.new(title: "", description: "", course_types: ['Ciencias'], user: @user)
    result = @course.save
    assert_not result
  end

end
