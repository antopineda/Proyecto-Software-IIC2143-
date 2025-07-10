class UserController < ApplicationController

    # My profile site
  def myprofile
    @courses = current_user.courses.order(created_at: :desc)
  end

  def show
    @user = User.find(params[:id])
    @courses = @user.courses.order(created_at: :desc)
    @completed_courses = []
    @enrolled_courses = Course.joins("INNER JOIN courses_taken ON courses.id = courses_taken.course_id")
                              .where(courses_taken: { user_id: @user.id })
    @enrolled_courses.each do |course|
      @lessons = course.lessons
      total_lessons = @lessons.count
      completed_lessons = @lessons.select do |lesson|
        # Verifica si hay una Submission para el único quiz asociado a dicha lección
        Submission.where(user: @user, quiz: lesson.quiz).exists?
      end.count
  
      if total_lessons > 0
        @lesson_progress_percentage = (completed_lessons.to_f / total_lessons) * 100
        puts @lesson_progress_percentage
      else
        @lesson_progress_percentage = 0
      end

      if @lesson_progress_percentage == 100
        @completed_courses << course
      end
    end 
    @actual_courses = @enrolled_courses - @completed_courses
  end

end
