class Review < ApplicationRecord

  ## ASSOCIATIONS ##
  belongs_to :user
  belongs_to :course

  ## VALIDATIONS ##
  validates :title, :body, :calification, presence: true

end
