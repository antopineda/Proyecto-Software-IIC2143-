class Submission < ApplicationRecord

  ## ASSOCIATIONS ##
  belongs_to :user
  belongs_to :quiz

end
