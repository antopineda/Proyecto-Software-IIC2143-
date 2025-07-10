require "test_helper"

class SubmissionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = User.create(email: "test@example.com", password: Devise::Encryptor.digest(User, 'password'), name: "name")
    @professor = User.create(email: "john@email.com", password: Devise::Encryptor.digest(User, 'password'), 
                             name: "professor")
    @course = Course.create(title: "Course Title", description: "Course Description", course_types: ['Ciencias'], 
                            user: @professor)
    @lesson = Lesson.create(title: "Lesson Title", content: "Lesson Description", course: @course, 
                            number_of_questions_in_quiz: 1)
    @quiz = Quiz.create(title: "Quiz Title", lesson: @lesson)

    @question1 = Question.create(quiz: @quiz, content: "Question 1", correct_answer: 1)
    @question2 = Question.create(quiz: @quiz, content: "Question 2", correct_answer: 2)

    sign_in @user
  end
  
    # TEST 1: Verifica que el show de una submission sea accesible
  test "should get show" do
        submission = Submission.create(quiz: @quiz, user: @user, score: 50, 
                                       user_answers: { @question1.id.to_s => 1, @question2.id.to_s => 2 })
      get course_lesson_quiz_submission_path(@course, @lesson, @quiz, submission)
      assert_response :ok
      end


    # TEST 3: Verifica que no se pueda crear una submission si ya existe una
  test "should not create submission if already exists" do
    Submission.create(quiz: @quiz, user: @user, score: 50, 
                      user_answers: { @question1.id.to_s => 1, @question2.id.to_s => 2 })
      assert_no_difference('Submission.count') do
        post course_lesson_quiz_submissions_path(@course, @lesson, @quiz), params: {
            question_1: 1,
            question_2: 2
        }
      end
      assert_redirected_to course_lesson_quiz_submission_path(@course, @lesson, @quiz, Submission.last)
      assert_equal "Ya has respondido este quiz.", flash[:alert]
  end

  test "should create submission if not exists" do
    assert_difference('Submission.count', 1) do
      post course_lesson_quiz_submissions_path(@course, @lesson, @quiz), params: {
          score: 50,
          user_answers: { @question1.id.to_s => 1, @question2.id.to_s => 2 }
      }
    end
      assert_redirected_to course_lesson_quiz_submission_path(@course, @lesson, @quiz, Submission.last)
  end
end
