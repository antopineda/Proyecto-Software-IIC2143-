class EnrollmentRequest < ApplicationRecord
  belongs_to :user
  belongs_to :course
  has_one_attached :payment_proof

  enum status: { pending: 'pending', accepted: 'accepted', rejected: 'rejected' }

end
