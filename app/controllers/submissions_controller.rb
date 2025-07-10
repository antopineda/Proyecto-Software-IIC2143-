class SubmissionsController < ApplicationController
  before_action :find_submission, only: [:show]
  
  def show
    @course = Course.find(params[:course_id])
    @lesson = Lesson.find(params[:lesson_id])
    @quiz = @submission.quiz
  end
  
  def create
    @course = Course.find(params[:course_id])
    @lesson = Lesson.find(params[:lesson_id])
    @quiz = Quiz.find(params[:quiz_id])

    if !(current_user.id == @course.user_id)
      # Se verifica si ya existe una submission para este usuario y quiz (es decir, si ya respondió este quiz)
      existing_submission = Submission.find_by(quiz: @quiz, user: current_user)

      if Submission.exists?(quiz: @quiz, user: current_user)
        redirect_to course_lesson_quiz_submission_path(@course, @lesson, @quiz, existing_submission), 
                    alert: "Ya has respondido este quiz."
        return
      end

      user_answers = {}
      correct_answers = 0

      params.each do |key, value|
        next unless key.start_with?('question_')
        question_id = key.split('_').last.to_i
        selected_answer = value.to_i
        user_answers[question_id.to_s] = selected_answer
        question = Question.find(question_id)

        if question.correct_answer == selected_answer
          correct_answers += 1
        end
      end

      score = (correct_answers.to_f / @quiz.questions.count) * 100
      submission = Submission.new(
        quiz: @quiz, 
        user: current_user, 
        score: score, 
        user_answers: user_answers)

      if submission.save
        redirect_to course_lesson_quiz_submission_path(@course, @lesson, @quiz, submission)
      else
        flash[:alert] = "ERROR AL CREAR LA SUBMISSION"
        puts "NO SE ESTA GUARDANDO"
      end
    else
      redirect_to course_lesson_quizzes_path(@course, @lesson), 
                  alert: 'Eres el dueño del curso, por lo que no puedes responder el quiz'
    end
  end

  private

  def find_submission
    @submission = Submission.find(params[:id])
  end

  def submission_params
    params.require(:submission).permit(:course_id, :lesson_id, :quiz_id, :user_id, :score, user_answers: {})
  end

end
