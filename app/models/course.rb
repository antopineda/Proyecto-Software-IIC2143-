class Course < ApplicationRecord

    ## ASSOCIATIONS ##
  belongs_to :user
  has_many :reviews, dependent: :destroy
  has_and_belongs_to_many :taken_by, class_name: "User", join_table: "courses_taken"
  has_many :enrollment_requests, dependent: :destroy
    
        # Relación con lessons
  has_many :lessons, dependent: :destroy

  has_one :room, dependent: :destroy
  has_and_belongs_to_many :histories, class_name: "User", join_table: "histories"

    ## VALIDATIONS ##
  # Definimos las opciones permitidas para 'type'
  COURSE_TYPES = ['Ciencias', 'Matemáticas', 'Ciencias Sociales', 'Deporte', 'Recreación', 'Arte', 'PAES', 
                  'Universitario', 'Técnico', 'Idiomas', 'Otro']

  validates :course_types, presence: true, length: { minimum: 1, maximum: 3 }
  validates :title, :description, presence: true
  validate :valid_course_types

  def progress_for(user)
    total_lessons = lessons.count
    completed_lessons = lessons.joins(:progresses).where('progresses.user_id = ? AND progresses.completed_lesson = ?', 
                                                         user.id, true).count
    
    total_quizzes = lessons.joins(:quizzes).count
    completed_quizzes = lessons.joins(quizzes: :progresses).where(
'progresses.user_id = ? AND progresses.completed_quiz = ?', user.id, true).count
    
    {
      lessons: { completed: completed_lessons, total: total_lessons },
      quizzes: { completed: completed_quizzes, total: total_quizzes }
    }
  end

  private

  def valid_course_types
    if course_types.length < 1 || course_types.length > 3
      errors.add(:course_types, "Debes seleccionar entre 1 y 3 tipos de curso")
    end
  end 

  ## VALIDATIONS ##

  # Callback para crear la sala automáticamente
  after_create :create_room

  private

  def create_room
    Room.create(course: self, name: "Chat del Curso") # Crear la sala de chat
  end

end