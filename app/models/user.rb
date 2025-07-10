class User < ApplicationRecord

  ## ASSOCIATIONS ##

  # Relación de uno a muchos con cursos (un profesor puede tener varios cursos)
  has_many :courses, dependent: :destroy

  # Relación de uno a muchos con submissions
  has_many :submissions, dependent: :destroy

  # Relación de uno a muchas con reviews
  has_many :reviews, dependent: :destroy

  # Relación de uno a muchos con enrollment_requests
  has_many :enrollment_requests, dependent: :destroy

  # Relación de muchos a muchos con cursos a través de la tabla intermedia "courses_taken"
  has_and_belongs_to_many :courses_taken, class_name: "Course", join_table: "courses_taken"
  has_and_belongs_to_many :histories, class_name: "Course", join_table: "histories"

  # Relación de uno a muchos con mensajes
  has_many :messages, dependent: :destroy

  ## VALIDATIONS ##
  validates :email, :encrypted_password, :name, presence: true

  ## DEVISE AUTOMATIC ##

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  ## EXTRA ##
  has_one_attached :profile_picture

  def professor_of?(course)
    self.id == course.user_id
  end
  
  def enrolled_in?(course)
    courses_taken.exists?(id: course.id) ####aca!!!!
  end
  has_many :progresses
  has_many :lessons, through: :progresses
  has_many :quizzes, through: :progresses
  

end
