class RoomsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_course
  before_action :set_room
  before_action :check_enrollment, only: [:show]

  # Acción para mostrar la sala de chat
  def show
    # @room ya ha sido encontrado en set_room
    @course = Course.find(params[:course_id])
    @room = Room.find(params[:id])
    @messages = @room.messages.includes(:user).order(created_at: :asc)
    @message = Message.new
  end

  private

  # Busca el curso al que pertenece la sala
  def set_course
    @course = Course.find(params[:course_id])
  end

  # Busca la sala de chat asociada al curso
  def set_room
    @room = @course.room
  end
  

  # Verifica si el usuario tiene acceso al curso
  def check_enrollment
    @course = Course.find(params[:course_id]) 
    unless current_user.professor_of?(@course) || current_user.enrolled_in?(@course) || current_user.admin
      redirect_to root_path, alert: "No tienes acceso a esta sala de chat."
    end
  end

end

