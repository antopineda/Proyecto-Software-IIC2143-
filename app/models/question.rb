class Question < ApplicationRecord

  ## ASSOCIATIONS ##
  belongs_to :quiz

  ## ACTIVE STORAGE ##
  has_one_attached :image

  ## VALIDATIONS ##
  validates :correct_answer, inclusion: { in: 1..4 }

end
