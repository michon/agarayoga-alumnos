require "test_helper"

class HorarioControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get horario_index_url
    assert_response :success
  end
end
