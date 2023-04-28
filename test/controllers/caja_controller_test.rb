require "test_helper"

class CajaControllerTest < ActionDispatch::IntegrationTest
  test "should get listado" do
    get caja_listado_url
    assert_response :success
  end

  test "should get modificar" do
    get caja_modificar_url
    assert_response :success
  end

  test "should get ver" do
    get caja_ver_url
    assert_response :success
  end
end
