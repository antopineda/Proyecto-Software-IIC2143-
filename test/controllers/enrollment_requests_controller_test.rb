require "test_helper"

class EnrollmentRequestsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  def setup
    @user = User.create(email: "test@example.com", password: Devise::Encryptor.digest(User, 'password'), name: "name")
    @professor = User.create(email: "prof@example.com", password: Devise::Encryptor.digest(User, 'password'), 
                             name: "professor", professor: true)
    @course = Course.create(title: "Title", description: "This is the description of the course", 
                            course_types: ['Ciencias'], user: @professor)
    sign_in @user # Autenticar al usuario
  end

  test "create and update enrollment request" do
    # Crear una solicitud de inscripción
    assert_difference 'EnrollmentRequest.count', 1 do
      @payment_proof = fixture_file_upload('payment_proof.png', 'image/png')
      post course_enrollment_requests_path(@course), params: { enrollment_request: { payment_proof: @payment_proof } }
    end
    assert_redirected_to course_path(@course)
    assert_equal 'Solicitud de inscripción enviada.', flash[:notice]

    # Cambiar a profesor y actualizar el estado de la solicitud de inscripción
    sign_in @professor
    @enrollment_request = EnrollmentRequest.last
    patch enrollment_request_path(@enrollment_request), params: { status: 'accepted' }
    assert_redirected_to pending_requests_enrollment_requests_path
    assert_equal 'accepted', @enrollment_request.reload.status
  end

  test "destroy rejected request and create new enrollment request" do
    # Crear una solicitud rechazada y luego intentar crear una nueva
    @rejected_request = EnrollmentRequest.create(user: @user, course: @course, status: 'rejected')
    assert_no_difference 'EnrollmentRequest.count' do
      post course_enrollment_requests_path(@course), params: { enrollment_request: {} }
    end
    assert_redirected_to course_path(@course)
  end
end
