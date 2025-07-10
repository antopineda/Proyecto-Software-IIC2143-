class LessonsController < ApplicationController
  before_action :check_enrollment, only: [:show, :index]

  def index
    @course = Course.find(params[:course_id])
      @lessons = @course.lessons
      redirect_to course_path(@course.id)
  end

  def create
    @course = Course.find(params[:course_id])
      @lesson= @course.lessons.new(lesson_params)

      if !(current_user.id == @course.user_id)
        redirect_to course_path(@course), 
                    alert: 'Este curso no es tuyo, por lo que no tienes permiso para realizar esta acción.' and return
      elsif @lesson.number_of_questions_in_quiz == 0 or @lesson.number_of_questions_in_quiz == nil
        redirect_to course_lessons_path(@course), 
                    alert: 'Debes marcar algún valor distintos de 0 para el número de preguntas para el quiz' and return
      end

      if @lesson.save
        redirect_to course_path(@course.id)
      else
        render :new, status: :unprocessable_entity
      end
  end

  def new
    @course = Course.find(params[:course_id])
      @lesson = Lesson.new

      unless current_user.id == @course.user_id
        redirect_to course_path(@course), 
                    alert: 'Este curso no es tuyo, por lo que no tienes permiso para realizar esta acción.'
      end
  end

  def show
    @course = Course.find(params[:course_id])
      @profesor = User.find(@course.user_id).name
      @lesson = Lesson.find(params[:id])
  end

  def destroy
    @course = Course.find(params[:course_id])
      @lesson = Lesson.find(params[:id])

      if current_user.id == @course.user_id or current_user.admin
        if @lesson.destroy
          redirect_to course_path(@course)
        end
      else
        redirect_to course_path(@course), \
                    alert: 'Este curso no es tuyo, por lo que no tienes permiso para realizar esta acción.', \
                    status: :forbidden
      end
  end

    private

  def lesson_params
    params.require(:lesson).permit(:title, :content, :number_of_questions_in_quiz, :video, :pdf)
  end

  def check_enrollment
    @course = Course.find(params[:course_id])
      unless user_signed_in? && (current_user.courses_taken.include?(@course) ||
                                 current_user.id == @course.user_id ||
                                 current_user.admin)
        if user_signed_in?
          redirect_to course_path(@course.id), 
                      alert: "Debes estar inscrito en el curso para acceder a las lecciones."
        else
          redirect_to new_user_session_path, alert: "Debes iniciar sesión para acceder a las lecciones."
        end
      end
  end

end