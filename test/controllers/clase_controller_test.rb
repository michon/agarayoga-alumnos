require "test_helper"

class ClaseControllerTest < ActionDispatch::IntegrationTest
  test "should get semana" do
    get clase_semana_url
    assert_response :success
  end

  test "should get actual" do
    get clase_actual_url
    assert_response :success
  end
end
