require "test_helper"

class QuizzesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create(email: "test@example.com", password: Devise::Encryptor.digest(User, 'password'), 
                        name: "name")
      @professor = User.create(email: "prof@email.com", password: Devise::Encryptor.digest(User, 'password'), 
                               name: "professor", professor: true)
      @course = Course.create(title: "Title", description: "This is the description of the course", 
                              course_types: ['Ciencias'], user: @professor)
      @lesson = Lesson.create(title: "Title", content: "This is the description of the lesson", course: @course, 
                              number_of_questions_in_quiz: 1)
  end

    # TEST 1
  test "should get index" do
    sign_in @user
      @quiz = Quiz.create(title: "Title", lesson: @lesson)
      @user.courses_taken << @course
      get course_lesson_quizzes_path(@course, @lesson)
      assert_response :ok
  end
  
  # TEST 2
  test "should get new" do
        sign_in @professor
      get new_course_lesson_quiz_path(@course, @lesson)
      assert_response :ok
      end

    # TEST 3
  test "should not get new if not professor" do
    sign_in @user
      get new_course_lesson_quiz_path(@course, @lesson)
      assert_response 302
  end

    # TEST 4
  test "create quiz when professor is logged in" do
    sign_in @professor
      assert_difference('Quiz.count') do
        post course_lesson_quizzes_path(@course, @lesson), params: {
            quiz: { title: 'Nuevo quiz', lesson: @lesson }
        }
      end
      assert_redirected_to course_lesson_quizzes_path(@course, @lesson)
  end

    # TEST 5
  test "should get show" do
    sign_in @user
      @quiz = Quiz.create(title: "Title", lesson: @lesson)
      @submission = Submission.create(user: @user, quiz: @quiz, score: 50, user_answers: {"6":3})
      get course_lesson_quiz_path(@course, @lesson, @quiz)
  end

    # TEST 6
  test "should destroy quiz" do
    sign_in @professor
      @quiz = Quiz.create(title: "Title", lesson: @lesson)

      # Verifica que el quiz se haya creado
      assert_difference('Quiz.count', -1) do
        delete course_lesson_quiz_path(@course, @lesson, @quiz)
      end

      # Verifica que redirija a la ruta correcta
      assert_redirected_to course_lesson_quizzes_path(@course, @lesson)
      
      # Verifica el mensaje de éxito
      follow_redirect!
      assert_select 'div', text: "El quiz fue eliminado."
  end

    # TEST 7
  test "should update quiz" do
    sign_in @professor  # Inicia sesión como profesor con permisos de actualización

      # Crea un quiz asociado a la lección y define un nuevo título
      @quiz = Quiz.create(title: "Original Title", lesson: @lesson)
      new_title = "Updated Title"

      # Realiza la solicitud PATCH para actualizar el quiz y verifica que se ha cambiado el título
      patch course_lesson_quiz_path(@course, @lesson, @quiz), params: { quiz: { title: new_title } }

      # Recarga el quiz desde la base de datos para asegurarse de que se actualizó
      @quiz.reload

      # Verifica que el título del quiz haya cambiado
      assert_equal new_title, @quiz.title

      # Verifica que se redirige a la ruta correcta después de la actualización
      assert_redirected_to course_lesson_quizzes_path(@course, @lesson)

      # Verifica que el mensaje de éxito se muestra en la redirección
      follow_redirect!
      assert_select 'div', text: "El quiz fue actualizado con éxito."
  end

end