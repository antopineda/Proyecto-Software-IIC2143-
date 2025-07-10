class Progress < ApplicationRecord
  belongs_to :user
  belongs_to :lesson
  belongs_to :quiz, optional: true
end
