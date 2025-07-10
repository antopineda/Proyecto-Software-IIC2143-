class Quiz < ApplicationRecord

    ## ASSOCIATIONS ##
  belongs_to :lesson
  has_many :questions, dependent: :destroy
  has_many :submissions, dependent: :destroy
  accepts_nested_attributes_for :questions, allow_destroy: true, reject_if: :all_blank
  has_many :progresses

    ## METHODS ##
  def correct_answer_text
    send("answer #{correct_answer}")
  end
end
