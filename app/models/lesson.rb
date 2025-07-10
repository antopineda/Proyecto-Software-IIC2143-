class Lesson < ApplicationRecord

  ## ASSOCIATIONS ##
  belongs_to :course
  has_one :quiz, dependent: :destroy

  ## ACTIVE STORAGE ##
  has_one_attached :video
  has_one_attached :pdf

  has_many :progresses

  ## VALIDATIONS ##
  validates :title, presence: true
  
end
