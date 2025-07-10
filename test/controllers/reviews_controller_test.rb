require "test_helper"

class ReviewsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create(email: "test@example.com", password: Devise::Encryptor.digest(User, 'password'), 
                        name: "name")
    @professor = User.create(email: "prof@email.com", password: Devise::Encryptor.digest(User, 'password'), 
                             name: "professor", professor: true)
    @course = Course.create(title: "Title", description: "This is the description of the course", 
                            course_types: ['Ciencias'], user: @professor)
    @user.courses_taken << @course
    @review = Review.create(title: "Title", body: "This is the body of the review", calification: 3, user: @user, 
                            course: @course)
  end

    # TEST 1
  test "should get index" do
    get course_reviews_path(@course)
  assert_response :ok
  end

    # TEST 2
  test "should get new" do
    sign_in @user
    get new_course_review_path(@course)
  assert_response 302
  end

  # TEST 4
  test "should get show" do
    sign_in @user
    get course_review_path(@course, @review)
    assert_response :ok
  end

  # TEST 5
# test "should create review" do
#   sign_in @user
#   @new_course = Course.create(title: "Title New", description: "This is the description of the course",
#                               course_types: ['Otro'], user: @professor)
#   @user.courses_taken << @new_course

#   # Simulamos que todas las lecciones del curso están completadas
#   @new_course.lessons.each do |lesson|
#     allow(Submission).to receive(:where).and_return(double(exists?: true)) # Simula que la lección está completada
#   end

#   assert_difference('Review.count') do
#     post course_reviews_path(@new_course), params: {
#       review: { title: 'Nuevo review', body: 'Descripción', calification: 5 }
#     }
#   end
#   assert_response 302
# end
  # Caso cuando el usuario no ha completado todas las lecciones
  test "should not create review if course is not completed" do
    sign_in @user
    @lesson = @course.lessons.create(title: 'Lesson 1', content: 'Lesson content', number_of_questions_in_quiz: 1)
    @quiz = @lesson.quiz
    @submission = Submission.create(user: @user, quiz: @quiz, score: 100, user_answers: {"6":3})
    # Simula que el usuario no ha completado todas las lecciones (no hay submission)
    @course.lessons.each do |lesson|
      Submission.where(user: @user, quiz: lesson.quiz).destroy_all
    end

    sign_in @user
    post course_reviews_path(@course.id), params: { review: { content: 'Great course!' } }

    assert_redirected_to course_reviews_path(@course)
    assert_equal 'Debes haber terminado el curso para crear una review en este curso', flash[:alert]
  end


  # TEST 6
  test "should update review" do
    sign_in @user
    patch course_review_path(@course, @review), params: {
      review: { title: 'Updated review', body: 'Descripción', calification: 4 }
    }
    assert_response :ok
  end

  # TEST 7
  test "should destroy review" do
    sign_in @user
    assert_difference('Review.count', -1) do
      delete course_review_path(@course, @review)
    end
    assert_redirected_to course_reviews_path(@course)
  end
  
end
