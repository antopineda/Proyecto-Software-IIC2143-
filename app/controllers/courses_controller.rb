class CoursesController < ApplicationController

    # Solo los usuarios autenticados pueden acceder a ciertas acciones
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy, :subscribe, :unsubscribe]

    # Solo los profesores / admin pueden crear, editar o eliminar cursos
  before_action :authenticate_professor, only: [:new, :create, :edit, :update, :destroy]

  def index
    @courses = Course.all.order(created_at: :desc)

    if params[:search].present?
      search_query = "%#{params[:search]}%"
      
      # Búsqueda en el título, la descripción, el nombre del profesor y las categorías
      @courses = @courses.joins(:user).where(
        "courses.title ILIKE :search OR courses.description ILIKE :search OR users.name ILIKE 
        :search OR :search = ANY(courses.course_types)",
        search: search_query
      )
    end
  
    # Aplicamos los filtros por categoría y profesor solo si están presentes
    if params[:category].present?
      @courses = @courses.where("? = ANY(course_types)", params[:category])
    end
  
    if params[:professor].present?
      @courses = @courses.joins(:user).where(users: { name: params[:professor] })
    end
  
  end

  def create
    if current_user.professor
      @course = current_user.courses.new(course_params)
      if @course.save
        redirect_to courses_path
      else
        flash.now[:alert] = 'No se pudo crear el curso.'
        render :new, status: :unprocessable_entity
      end
    else
      redirect_to courses_path, alert: 'No tienes permisos para crear un curso'
    end
  end

  def new
    if current_user.professor
      @course = Course.new
    else
      redirect_to courses_path, alert: 'No tienes permisos para crear un curso'
    end
  end

  def edit
    @course = Course.find(params[:id])

      unless current_user.id == @course.user_id or current_user.admin
        redirect_to course_path(@course), 
                    alert: 'Este curso no es tuyo, por lo que no tienes permiso para realizar esta acción.'
      end
  end

  def show
    @course = Course.find(params[:id])
    @lessons = @course.lessons
    @enrollment_request = EnrollmentRequest.new
    @room = @course.room

    # Ver cantidad de estudiantes
    @contador = 0
    @course.taken_by.each do |student|
      @contador += 1
    end
    @contador += 1

    @professor = @course.user
    
    if @course.reviews.present?
      # Se busca el rating hasta la fecha del curso
      sum = 0
      number_of_reviews = 0
      @reviews = @course.reviews
      @reviews.each do |review|
        puts review
        puts review.calification
        sum += review.calification
        number_of_reviews += 1
      end

      @course.calification = (sum / number_of_reviews)
    end

    # # Calcular quizzes completados usando el modelo Submission
    # total_quizzes = @lessons.sum { |lesson| lesson.quizzes.count }
    # completed_quizzes = Submission.where(user: current_user, quiz: @lessons.map(&:quizzes).flatten).count

    # if total_quizzes > 0
    #   @quiz_progress_percentage = (completed_quizzes.to_f / total_quizzes) * 100
    # else
    #   @quiz_progress_percentage = 0
    # end

    # # Calcular lecciones completadas (si todos los quizzes de una lección tienen una submission)
    # total_lessons = @lessons.count
    # completed_lessons = @lessons.select do |lesson|
    #   lesson.quizzes.all? { |quiz| Submission.where(user: current_user, quiz: quiz).exists? }
    # end.count

    # if total_lessons > 0
    #   @lesson_progress_percentage = (completed_lessons.to_f / total_lessons) * 100
    # else
    #   @lesson_progress_percentage = 0
    # end

    # Calcular el porcentaje de avance (quizzes completados / numero de lessons)
    total_lessons = @lessons.count
    completed_lessons = @lessons.select do |lesson|
      # Verifica si hay una Submission para el único quiz asociado a dicha lección
      Submission.where(user: current_user, quiz: lesson.quiz).exists?
    end.count

    if total_lessons > 0
      @lesson_progress_percentage = (completed_lessons.to_f / total_lessons) * 100
      puts @lesson_progress_percentage
    else
      @lesson_progress_percentage = 0
    end
  end


  def update
    @course = Course.find(params[:id])

      if current_user.id == @course.user_id or current_user.admin
        if @course.update(course_params)
          redirect_to course_path(@course)
        else
          flash.now[:alert] = 'No se pudo actualizar el curso.'
            render :edit, status: :unprocessable_entity
        end
      else
        redirect_to course_path(@course), \
                    alert: 'Este curso no es tuyo, por lo que no tienes permiso para realizar esta acción.', \
                    status: :forbidden
      end
  end

  def destroy
    @course = Course.find(params[:id])
      if current_user.id == @course.user_id or current_user.admin
        if @course.destroy
          redirect_to courses_path
        end
      else
        redirect_to course_path(@course), \
                    alert: 'Este curso no es tuyo, por lo que no tienes permiso para realizar esta acción.', \
                    status: :forbidden
      end
  end

  def unsubscribe
    @course = Course.find(params[:id])

      # Eliminar la inscripción del usuario del curso
      enrollment_request = current_user.enrollment_requests.find_by(course: @course)
      enrollment_request.destroy if enrollment_request.present?
  
      # Eliminar la inscripción del usuario del curso
      if current_user.courses_taken.include?(@course)
        current_user.courses_taken.delete(@course)
        redirect_to course_path(@course.id), notice: 'Te has dado de baja del curso.'
        # Agregar a tabla histories
        if current_user.histories.include?(@course)
          current_user.histories.delete(@course)
        end
        current_user.histories << @course

      else
        redirect_to course_path(@course.id), alert: 'No estás inscrito en este curso.'
      end
    end

    private

  def course_params
    params.require(:course).permit(:title, :description, :price, course_types: []).tap do |whitelisted|
      whitelisted[:course_types].reject!(&:blank?) if whitelisted[:course_types]
    end
  end

  def authenticate_professor
    unless current_user.professor? or current_user.admin
      redirect_to courses_path, alert: 'No tienes permiso para realizar esta acción.'
    end
  end

end