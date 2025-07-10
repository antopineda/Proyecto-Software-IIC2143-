class RenderController < ApplicationController


  def index
    # Obtener los cursos en los que el usuario está inscrito
    if current_user
      @enrolled_courses = Course.joins("INNER JOIN courses_taken ON courses.id = courses_taken.course_id")
                                .where(courses_taken: { user_id: current_user.id })
                                
      # Obtener los cursos creados por el usuario
      @created_courses = Course.where(user_id: current_user.id)

      #Obtener cursos completados
      @completed_courses = []

      # unless @enrolled_courses.empty?
      #   for course in @enrolled_courses
      #     @lessons = course.lessons

      #     # Calcular quizzes completados usando el modelo Submission
      #     total_quizzes = @lessons.sum { |lesson| lesson.quizzes.count }
      #     completed_quizzes = Submission.where(user: current_user, quiz: @lessons.map(&:quizzes).flatten).count

      #     if total_quizzes > 0
      #       @quiz_progress_percentage = (completed_quizzes.to_f / total_quizzes) * 100
      #     else
      #       @quiz_progress_percentage = 0
      #     end

      #     if @quiz_progress_percentage == 100
      #       @completed_courses << course
      #     end
      #   end
      # end

      unless @enrolled_courses.empty?
        for course in @enrolled_courses
          @lessons = course.lessons
          
          # Calcular quizzes completados usando el modelo Submission
          total_quizzes = @lessons.count # Cada lección tiene un solo quiz
          completed_quizzes = Submission.where(user: current_user, quiz: @lessons.map(&:quiz)).count
      
          if total_quizzes > 0
            @quiz_progress_percentage = (completed_quizzes.to_f / total_quizzes) * 100
          else
            @quiz_progress_percentage = 0
          end

          if @quiz_progress_percentage == 100
            @completed_courses << course
          end
        end
      end
      
      @actual_courses = @enrolled_courses - @completed_courses

      # Obtener histories
      @histories = Course.joins("INNER JOIN histories ON courses.id = histories.course_id")
                         .where(histories: { user_id: current_user.id })

    end
  end
  
  # About ClassMate method
  def about
  end
  
end
