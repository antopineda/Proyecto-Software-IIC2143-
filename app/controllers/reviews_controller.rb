class ReviewsController < ApplicationController
  
  # Solo los usuarios autenticados pueden acceder a ciertas acciones
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]

  # Cualquier tipo de usuario puede ver las reviews de un determinado curso.
  def index
    @course = Course.find(params[:course_id])
    @reviews = @course.reviews.order(created_at: :desc)
  end

  # Solo los usuarios que pertenecen al curso y no han dejado una review aún pueden acceder al formulario "new"
  def create
    @course = Course.find(params[:course_id])
    @lessons = @course.lessons

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

    if @lesson_progress_percentage == 100
      condition = true
      @course.reviews.each do |review|
        if current_user.id == review.user_id
          condition = false
        end
      end

      # Se crea instancia de review para luego verificar si puede ser guardada en base de datos
      @review = @course.reviews.new(review_params)
      @review.user_id = current_user.id

      if current_user.courses_taken.include?(@course) && condition == true
        if @review.save
          redirect_to course_reviews_path(@course.id)
        else
          flash[:alert] = 'No se pudo guardar la reseña. Por favor, completa todos los campos requeridos.'
          render :new, status: :unprocessable_entity
        end
      else
        redirect_to course_reviews_path(@course), alert: 'No estás habilitado para crear una review en este curso'
      end
    else
      redirect_to course_reviews_path(@course), 
                  alert: 'Debes haber terminado el curso para crear una review en este curso'
    end
  end

  # Solo los usuarios que pertenecen al curso y no han dejado una review aún pueden acceder al formulario "new"
  def new
    @course = Course.find(params[:course_id])
    @review = Review.new

    condition = true
    @course.reviews.each do |review|
      if current_user.id == review.user_id
        condition = false
      end
    end

    unless current_user.courses_taken.include?(@course) && condition == true
      redirect_to course_reviews_path(@course), alert: 'No estás habilitado para crear una review en este curso'
    end
  end

  def edit
  end

  def show
    @course = Course.find(params[:course_id])
    @review = Review.find(params[:id])
  end

  def update
  end

  def destroy
    @course = Course.find(params[:course_id])
    @review = Review.find(params[:id])

    if current_user.id == @review.user_id or current_user.admin
      @review.destroy
      redirect_to course_reviews_path(@course), notice: 'Review eliminada exitosamente.'
    else
      redirect_to course_review_path(@course), 
                  alert: "Esta review no te pertenece, por lo que no tienes permiso para realizar esta acción."
    end
  end

  private

  def review_params
    params.require(:review).permit(:title, :body, :calification)
  end

end
