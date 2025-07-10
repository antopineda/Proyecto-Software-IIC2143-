require "test_helper"

class QuestionsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
    
  setup do
    @user = User.create(email: "user@example.com", password: Devise::Encryptor.digest(User, 'password'), 
                        name: "name")
      @professor = User.create(email: "prof@example.com", password: Devise::Encryptor.digest(User, 'password'), 
                               name: "professor", professor: true)
      @course = Course.create(title: "Course Title", description: "Course Description", course_types: ['Ciencias'], 
                              user: @professor)
      @lesson = Lesson.create(title: "Lesson Title", content: "Lesson Description", course: @course)
      @quiz = Quiz.create(title: "Quiz Title", lesson: @lesson)
      sign_in @user
      @user.courses_taken << @course
  end

end
