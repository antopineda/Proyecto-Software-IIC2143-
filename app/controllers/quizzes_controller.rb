class QuizzesController < ApplicationController
  before_action :set_quiz, only: %i[ show edit update destroy ]

  # Solo los usuarios autenticados pueden optar a acceder a estas acciones
  before_action :authenticate_user!

  # Solo los usuarios profesores dueños del curso pueden hacer ciertas acciones
  before_action :authenticate_professor_owner_of_course, only: [:new, :edit, :create, :update, :destroy]

  # GET /quizzes or /quizzes.json
  def index
    @course = Course.find(params[:course_id])
    @lesson = Lesson.find(params[:lesson_id])
    @quiz = @lesson.quiz

    if Submission.exists?(quiz: @quiz, user: current_user)
      @submission = Submission.find_by(quiz: @quiz, user: current_user)
    end

    if Submission.exists?(quiz: @quiz)
      @average_score = 0
      @submissions = Submission.where(quiz: @quiz)
      @submissions.each do |submission|
        @average_score += submission.score
      end
      @average_score /= @submissions.count
    end

    # Pueden verlos los usuarios inscritos al curso o el profesor del curso
    unless (current_user.id == @course.user_id) || @course.taken_by.exists?(id: current_user.id) || current_user.admin
      redirect_to course_path(@course), 
                  alert: 'No tienes permiso para realizar esta acción.'
    end
  end

  # GET /quizzes/1 or /quizzes/1.json
  def show
    @course = Course.find(params[:course_id])
    @lesson = Lesson.find(params[:lesson_id])
    @quiz = Quiz.find(params[:id])

    # Se verifica si ya existe una submission para este usuario y quiz (es decir, si ya respondió este quiz)
    existing_submission = Submission.find_by(quiz: @quiz, user: current_user)

    if Submission.exists?(quiz: @quiz, user: current_user)
      redirect_to course_lesson_quiz_submission_path(@course, @lesson, @quiz, existing_submission), 
                  alert: "Ya has respondido este quiz."
      return
    end

    # Pueden ver este quiz los usuarios inscritos al curso o el profesor del curso
    unless (current_user.id == @course.user_id) || @course.taken_by.exists?(id: current_user.id) || current_user.admin
      redirect_to course_path(@course),
                  alert: 'No tienes permiso para realizar esta acción.'
    end
  end

  # GET /quizzes/new
  def new
    @course = Course.find(params[:course_id])
    @lesson = Lesson.find(params[:lesson_id])

    if !@lesson.quiz.present?
      if current_user.id == @course.user_id
        @quiz = Quiz.new
        @lesson.number_of_questions_in_quiz.times { @quiz.questions.build } #creates a question by default
      else
        redirect_to course_lesson_quizzes_path(@course, @lesson), 
                    alert: 'No tienes permiso para crear un quiz para esta lesson'
      end
    else
      redirect_to course_lesson_quizzes_path(@course, @lesson), alert: 'Ya existe un quiz para esta lesson'
    end
  end

  # GET /quizzes/1/edit
  def edit
    @course = Course.find(params[:course_id])
    @lesson = Lesson.find(params[:lesson_id])
    @quiz = Quiz.find(params[:id])
  end

  # POST /quizzes or /quizzes.json
  def create
    @course = Course.find(params[:course_id])
    @lesson = Lesson.find(params[:lesson_id])

    if !@lesson.quiz.present?
      @quiz = @lesson.build_quiz(quiz_params)

      respond_to do |format|
        if @quiz.save
          format.html {
  redirect_to course_lesson_quizzes_path(@course.id, @lesson.id), notice: "El quiz fue creado con éxito." }
          format.json { render :show, status: :created, location: @quiz }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @quiz.errors, status: :unprocessable_entity }
        end
      end
    else
      redirect_to course_lesson_quizzes_path(@course, @lesson), alert: 'Ya existe un quiz para esta lesson'
    end
  end

  # PATCH/PUT /quizzes/1 or /quizzes/1.json
  def update
    @course = Course.find(params[:course_id])
    @lesson = Lesson.find(params[:lesson_id])
    @quiz = Quiz.find(params[:id])

    respond_to do |format|
      if @quiz.update(quiz_params)
        format.html {
 redirect_to course_lesson_quizzes_path(@course, @lesson), notice: "El quiz fue actualizado con éxito." }
        format.json { render :show, status: :ok, location: @quiz }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @quiz.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /quizzes/1 or /quizzes/1.json
  def destroy
    @quiz.destroy
    @course = Course.find(params[:course_id])
    @lesson = Lesson.find(params[:lesson_id])

    respond_to do |format|
      format.html {
 redirect_to course_lesson_quizzes_path(@course, @lesson), notice: "El quiz fue eliminado." }
      format.json { head :no_content }
    end
  end

  def complete
    @quiz = Quiz.find(params[:id])
    @progress = Progress.find_or_create_by(user: current_user, quiz: @quiz)
    @progress.update(completed_quiz: true)
    
    check_lesson_completion(@quiz.lesson)
    
    redirect_to course_path(@quiz.lesson.course), notice: 'Quiz completado!'
  end

  private

    # Use callbacks to share common setup or constraints between actions.
  def set_quiz
    @quiz = Quiz.find(params[:id])
  end

    # Only allow a list of trusted parameters through.
  def quiz_params
    params.require(:quiz).permit(
      :title, 
      :image,
      questions_attributes: [:id, :_destroy, :content, :answer1, :answer2, 
                             :answer3, :answer4, :correct_answer, :image])
  end

  private

  def check_lesson_completion(lesson)
    if lesson.quizzes.all? { |quiz| Progress.exists?(user: current_user, quiz: quiz, completed_quiz: true) }
      Progress.find_or_create_by(user: current_user, lesson: lesson).update(completed_lesson: true)
    end
  end

  def authenticate_professor_owner_of_course
    @course = Course.find(params[:course_id])
    unless (current_user.id == @course.user_id) or current_user.admin
      redirect_to courses_path, alert: 'No tienes permiso para realizar esta acción.'
    end
  end

end
