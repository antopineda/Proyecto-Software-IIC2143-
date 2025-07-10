require "test_helper"

class RoomsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @user = User.create(email: "user@email.com", password: Devise::Encryptor.digest(User, 'password'), name: "user")
    @professor = User.create(email: "prof@email.com", password: Devise::Encryptor.digest(User, 'password'), 
                             name: "professor", professor: true)
    @course = Course.create(title: "Course Title", description: "Course Description", course_types: ['Ciencias'], 
                            user: @professor)
    @room = @course.room
    sign_in @user
    @user.courses_taken << @course
  end

  test "should show room" do
    get course_room_path(@course, @room)
    assert_response :ok
  end
end
