require "test_helper"

class LessonTest < ActiveSupport::TestCase

  # TEST 1
  test "should not create a lesson without a title" do
    @user = User.create(email: "test@example.com", password: Devise::Encryptor.digest(User, 'password'), name: "name")
    @course = Course.new(title: "Title", description: "This is the description of the course", 
                         course_types: ['Ciencias'], user: @user)
    @lesson = Lesson.new(title: nil, content: "This is the content of the lesson", course: @course)
    result = @lesson.save
    assert_not result
  end

  # TEST 2
  test "should not create a lesson with an empty title" do
    @user = User.create(email: "test@example.com", password: Devise::Encryptor.digest(User, 'password'), name: "name")
    @course = Course.new(title: "Title", description: "This is the description of the course", 
                         course_types: ['Ciencias'], user: @user)
    @lesson = Lesson.new(title: "", content: "This is the content of the lesson", course: @course)
    result = @lesson.save
    assert_not result
  end

end
