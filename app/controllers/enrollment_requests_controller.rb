class EnrollmentRequestsController < ApplicationController
  before_action :authenticate_user!

  def create
    @course = Course.find(params[:course_id])

    # Verifica si ya existe una solicitud rechazada y la elimina
    existing_request = current_user.enrollment_requests.find_by(course: @course, status: :rejected)
    existing_request&.destroy

    if current_user.id == @course.user_id
      redirect_to course_path(@course), alert: 'No puedes inscribirte en tu propio curso.'
      return
    end
  
    unless current_user.enrollment_requests.exists?(course: @course)
      # Inicializa la solicitud de inscripción sin importar si se adjunta un comprobante
      @enrollment_request = @course.enrollment_requests.new(user: current_user, status: :pending)
      
      # Solo si el usuario adjunta un comprobante, se asigna
      if params[:payment_proof].present?
        @enrollment_request.payment_proof.attach(params[:payment_proof])
      end
  
      if @enrollment_request.save
        redirect_to course_path(@course), notice: 'Solicitud de inscripción enviada.'
      else
        redirect_to course_path(@course), alert: 'Error al enviar la solicitud.'
      end
    else
      redirect_to course_path(@course), alert: 'Ya has enviado una solicitud para este curso.'
    end
  end
    
  
  def update
    @enrollment_request = EnrollmentRequest.find(params[:id])

    if current_user == @enrollment_request.course.user # Solo el profesor puede aceptar/rechazar
      if params[:status] == 'accepted'
        @enrollment_request.update(status: :accepted)
        # Registrar al estudiante en el curso
        @enrollment_request.user.courses_taken << @enrollment_request.course
        if @enrollment_request.user.histories.include?(@enrollment_request.course)
          @enrollment_request.user.histories.delete(@enrollment_request.course)
        end
      elsif params[:status] == 'rejected'
        @enrollment_request.update(status: :rejected)
      end
      respond_to do |format|
        format.html {
 redirect_to pending_requests_enrollment_requests_path, notice: 'Solicitud actualizada correctamente.' }
        format.js   # Esto permitirá que se actualice mediante AJAX si lo necesitas
      end
    else
      redirect_to root_path, alert: 'No autorizado.'
    end
  end

  def update_request
    @enrollment_request = EnrollmentRequest.find(params[:enrollment_request_id])
    if current_user == @enrollment_request.user
      if @enrollment_request.update(enrollment_request_params)
        redirect_to enrollment_requests_pending_requests_path, notice: 'Solicitud actualizada correctamente.'
      else
        redirect_to enrollment_requests_pending_requests_path, alert: 'No se pudo actualizar la solicitud.'
      end
    else
      redirect_to root_path, alert: 'No autorizado.'
    end
  end

  def pending_requests
    # Encuentra todos los cursos que el profesor ha creado
    @courses = current_user.courses
    # Encuentra las solicitudes pendientes de esos cursos
    @pending_requests = EnrollmentRequest.where(course: @courses, status: :pending)
  end

  def index
    @enrollment_requests = current_user.enrollment_requests.includes(:course).order(created_at: :desc)
  end

  def cancel
    @course = Course.find(params[:course_id])
    @enrollment_request = current_user.enrollment_requests.find_by(course: @course)

    if @enrollment_request && @enrollment_request.destroy
      redirect_to course_path(@course), notice: 'Solicitud de inscripción cancelada correctamente.'
    else
      redirect_to course_path(@course), alert: 'No se pudo cancelar la solicitud de inscripción.'
    end
  end

  def pending_for_course
    @course = Course.find(params[:course_id])
    if current_user == @course.user # Verifica que el usuario sea el profesor del curso
      @enrollment_requests = @course.enrollment_requests.where(status: :pending).order(created_at: :desc)
    else
      redirect_to root_path, alert: 'No autorizado para ver las solicitudes de este curso.'
    end
  end

  private

  def enrollment_request_params
    params.permit(:payment_proof)
  end

end
