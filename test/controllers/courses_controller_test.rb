require "test_helper"

class CoursesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create(email: "test@example.com", password: Devise::Encryptor.digest(User, 'password'), name: "name")
    @professor = User.create(email: "prof@email.com", password: Devise::Encryptor.digest(User, 'password'), 
                             name: "professor", professor: true)
    @course = Course.create(title: "Title", description: "This is the description of the course", 
                            course_types: ['Ciencias'], user: @professor)
    sign_in @user
  end

  # Test Access to Views (Index, New, Edit, Show)
  test "should access views" do
    get courses_path, params: { search: "professor", category: 'Ciencias', professor: 'professor' }
    assert_response :ok

    get new_course_path
    assert_response 302

    get edit_course_path(@course)
    assert_response 302

    # Show with reviews
    @user1 = User.create(email: "user1@example.com", password: Devise::Encryptor.digest(User, 'password'), 
                         name: "user1")
    @user2 = User.create(email: "user2@example.com", password: Devise::Encryptor.digest(User, 'password'), 
                         name: "user2")
    @review1 = Review.create(title: "Review 1", body: "Body 1", calification: 5, user: @user1, course: @course)
    @review2 = Review.create(title: "Review 2", body: "Body 2", calification: 3, user: @user2, course: @course)
    get course_path(@course)
    assert_response :ok
  end

  # Test Create and Update Course
  test "should create and attempt to update course" do
    # Create course as professor
    sign_in @professor
    assert_difference('Course.count') do
      post courses_path, 
           params: { course: { title: 'Nuevo curso', description: 'Descripción', price: 50, course_types: ['Otro'] } }
    end
    assert_redirected_to courses_path

    # Attempt to create course as non-professor
    sign_in @user
    assert_no_difference('Course.count') do
      post courses_path, 
           params: { course: { title: 'Curso prohibido', description: 'Descripción', price: 50, 
course_types: ['Ciencias'] } }
    end
    assert_redirected_to courses_path
    assert_equal 'No tienes permiso para realizar esta acción.', flash[:alert]

    # Attempt to update course as non-owner
    patch course_path(@course), params: { course: { title: 'Intento de actualización' } }
    assert_redirected_to courses_path
    assert_equal 'No tienes permiso para realizar esta acción.', flash[:alert]

    # Render edit when update fails
    patch course_path(@course), params: { course: { title: '' } } # Invalid data
    assert_response 302
  end

  # Test Destroy and Unsubscribe from Course
  test "should not destroy if not owner and should unsubscribe from course" do
    # Attempt to destroy as non-owner
    sign_in @user
    assert_no_difference('Course.count') do
      delete course_path(@course)
    end
    assert_redirected_to courses_path
    assert_equal 'No tienes permiso para realizar esta acción.', flash[:alert]

    # Unsubscribe from course
    @user.courses_taken << @course
    @user.histories << @course
    @enrollment_request = EnrollmentRequest.create(user: @user, course: @course, status: 'accepted')
    delete unsubscribe_course_path(@course)

    assert_redirected_to course_path(@course.id)
    assert_equal 'Te has dado de baja del curso.', flash[:notice]
  end

  test "should update course" do
    sign_in @professor
    patch course_path(@course), params: { course: { title: 'Nuevo título' } }
    assert_redirected_to course_path(@course)
  end

  test "should destroy course" do
    sign_in @professor
    assert_difference('Course.count', -1) do
      delete course_path(@course)
    end
    assert_redirected_to courses_path
  end
end
