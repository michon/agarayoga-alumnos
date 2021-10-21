require "test_helper"

class InstructorControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get instructor_index_url
    assert_response :success
  end

  test "should get show" do
    get instructor_show_url
    assert_response :success
  end
end
