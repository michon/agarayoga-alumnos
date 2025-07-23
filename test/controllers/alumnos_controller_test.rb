require "test_helper"

class AlumnosControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get alumnos_index_url
    assert_response :success
  end

  test "should get show" do
    get alumnos_show_url
    assert_response :success
  end
end
