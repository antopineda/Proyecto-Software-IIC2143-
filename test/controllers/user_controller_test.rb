require "test_helper"

class UserControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = User.create(email: "test@example.com", password: Devise::Encryptor.digest(User, 'password'), name: "name")
    @course1 = Course.create(title: "Course 1", description: "This is the description of the course", 
                             course_types: ['Ciencias'], user: @user)
    @course2 = Course.create(title: "Course 2", description: "This is the description of the course", 
                             course_types: ['Otros'], user: @user)
    @another_user = User.create(email: "another@example.com", password: Devise::Encryptor.digest(User, 'password'), 
                                name: "another")
    @course3 = Course.create(title: "Course 3", description: "This is the description of the course",
                             course_types: ['Otro'], user: @another_user)
    @user.courses_taken << @course3
    sign_in @user # Simula el inicio de sesión del usuario
  end

  test "should get myprofile and display user's courses" do
    # Envía la solicitud GET al perfil del usuario
    get user_myprofile_path

    # Verifica la respuesta exitosa
    assert_response :success

    # Verifica que hay tarjetas de curso en la respuesta
    assert_select 'div.card', count: @user.courses.count

    # Verifica que los títulos de los cursos están en la respuesta
    @user.courses.each do |course|
      assert_select 'h5.card-title', text: /#{course.title}/
    end
  end

  test "should get show" do
    @lesson = Lesson.create(title: "Lesson Title", content: "Lesson Description", course: @course3, 
                            number_of_questions_in_quiz: 1)
    @quiz = Quiz.create(title: "Quiz Title", lesson: @lesson)
    @submission = Submission.create(user: @user, quiz: @quiz, score: 50, user_answers: {"6":3})
    get user_path(@user)
    assert_response :success
  end
end
