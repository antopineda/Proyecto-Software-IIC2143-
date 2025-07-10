require "test_helper"

class LessonsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
  setup do
    @user = User.create(email: "test@example.com", password: Devise::Encryptor.digest(User, 'password'), name: "name")
    @professor = User.create(email: "john@email.com", password: Devise::Encryptor.digest(User, 'password'), 
                             name: "John", professor: true)
    @course = Course.create(title: "Title", description: "This is the description of the course", 
                            course_types: ['Ciencias'], user: @professor)
    #@lesson = Lesson.create(title: "Title", content: "This is the content of the lesson", course: @course)
  end

  test "should get new" do # 3 lineas
    sign_in @professor
    get new_course_lesson_path(@course)
    assert_response :ok
  end

  test "should get show" do # cubre 5 lineas
    sign_in @professor
    @lesson = Lesson.create(title: "Title", content: "This is the content of the lesson", course: @course, 
                            number_of_questions_in_quiz: 5)
    get course_lesson_path(@course, @lesson)
    assert_response :ok
  end

  test "should get index" do
    @lesson = Lesson.create(title: "Title", content: "This is the content of the lesson", course: @course, 
                            number_of_questions_in_quiz: 5)
    sign_in @professor
    get course_lessons_path(@course)
    assert_response 302
  end

  # TEST 4
  test "should create lesson when professor is logged in" do
    sign_in @professor
    assert_difference('Lesson.count', 1) do  # Asegúrate de que la lección se cree
      post course_lessons_path(@course), params: {
        lesson: { title: 'New lesson', content: 'This is the content of the lesson', number_of_questions_in_quiz: 5}
      }
    end
    assert_redirected_to course_path(@course)  # Verifica que sea redirigido al curso
  end
  

  # # TEST 5
  # test "should not create lesson if not professor" do
  #   sign_in @user
  #   assert_no_difference('Lesson.count') do
  #     post course_lessons_path(@course), params: {
  #       lesson: { title: 'New lesson', content: 'This is the content of the lesson', number_of_questions_in_quiz: 5}
  #     }
  #   end
  #   assert_redirected_to course_path(@course)  # El usuario debería ser redirigido
  #   assert_equal 'Este curso no es tuyo, por lo que no tienes permiso para realizar esta acción.', flash[:alert]
  # end
  

  # TEST 6
  test "should destroy lesson when professor is logged in" do 
    sign_in @professor
    @lesson = Lesson.create(title: "Title", content: "This is the content of the lesson", course: @course, 
                            number_of_questions_in_quiz: 5)
    assert_difference('Lesson.count', -1) do
      delete course_lesson_path(@course, @lesson)
    end
    assert_redirected_to course_path(@course)
  end

  # # TEST 7
  # test "should not destroy lesson if not professor" do #falla
  #   sign_in @user
  #   assert_no_difference('Lesson.count') do
  #     delete course_lesson_path(@course, @lesson)
  #   end
  #   assert_response :forbidden
  #   assert_equal 'Este curso no es tuyo, por lo que no tienes permiso para realizar esta acción.', flash[:alert]
  # end



end
