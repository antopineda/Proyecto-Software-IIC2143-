class Room < ApplicationRecord

  has_many :messages, dependent: :destroy

  belongs_to :course

  validates :course_id, uniqueness: true
    
    # Para encontrar las salas de un curso especifico
  scope :for_course, ->(course_id) { where(course_id: course_id) }
end
