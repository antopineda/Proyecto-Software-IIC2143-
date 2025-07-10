require "test_helper"

class ReviewTest < ActiveSupport::TestCase

  # TEST 1
  test "should not create a review without a title" do
    @user = User.create(email: "test@example.com", password: Devise::Encryptor.digest(User, 'password'), name: "name")
    @course = Course.new(title: "Title", description: "This is the description of the course", 
                         course_types: ['Ciencias'], user: @user)
    @review = Review.new(title: nil, body: "This is the body of the review", calification: 3, course: @course)
    result = @review.save
    assert_not result
  end

  # TEST 2
  test "should not create a review without a body" do
    @user = User.create(email: "test@example.com", password: Devise::Encryptor.digest(User, 'password'), name: "name")
    @course = Course.new(title: "Title", description: "This is the description of the course", 
                         course_types: ['Ciencias'], user: @user)
    @review = Review.new(title: "Title", body: nil, calification: 3, user: @user, course: @course)
    result = @review.save
    assert_not result
  end

  # TEST 3
  test "should not create a review without a calification" do
    @user = User.create(email: "test@example.com", password: Devise::Encryptor.digest(User, 'password'), name: "name")
    @course = Course.new(title: nil, description: "This is the description", course_types: ['Ciencias'], 
                         user: @user)
    @review = Review.new(title: "Title", body: "This is the body of the review", calification: nil, user: @user, 
                         course: @course)
    result = @review.save
    assert_not result
  end

  # TEST 4
  test "should not create a review with an empty title" do
    @user = User.create(email: "test@example.com", password: Devise::Encryptor.digest(User, 'password'), name: "name")
    @course = Course.new(title: "Title", description: "This is the description", course_types: ['Ciencias'], 
                         user: @user)
    @review = Review.new(title: "", body: "This is the body of the review", calification: 3, user: @user, 
                         course: @course)
    result = @review.save
    assert_not result
  end

  # TEST 5
  test "should not create a review with an empty body" do
    @user = User.create(email: "test@example.com", password: Devise::Encryptor.digest(User, 'password'), name: "name")
    @course = Course.new(title: "Title", description: "This is the description", course_types: ['Ciencias'], 
                         user: @user)
    @review = Review.new(title: "Title", body: "", calification: 3, user: @user, course: @course)
    result = @review.save
    assert_not result
  end
  
end
