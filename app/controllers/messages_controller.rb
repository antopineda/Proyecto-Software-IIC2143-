class MessagesController < ApplicationController
  before_action :set_room
  before_action :check_user_enrollment_or_admin


  def create
    @message = @room.messages.new(message_params)
      @message.user = current_user

      if @message.save
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to course_room_path(@room.course, @room) }
        end
        else
          respond_to do |format|
            format.html { redirect_to course_room_path(@room.course, @room), alert: 'No se pudo enviar el mensaje' }
            format.turbo_stream do
                render turbo_stream: turbo_stream.replace("new_message_form", partial: "layouts/new_message_form", 
  locals: { message: @message })
              end
          end
      end
  end

    private

  def set_room
    @room = Room.find(params[:room_id])
  end

  def check_user_enrollment_or_admin
    unless current_user.enrolled_in?(@room.course) || current_user.professor_of?(@room.course) || current_user.admin
      redirect_to course_room_path(@room.course, @room), alert: 'No tienes permiso para enviar mensajes en este curso.'
    end
  end

  def message_params
    params.require(:message).permit(:body)
  end

end