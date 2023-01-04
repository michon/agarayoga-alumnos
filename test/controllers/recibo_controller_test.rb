require "test_helper"

class ReciboControllerTest < ActionDispatch::IntegrationTest
  test "should get pagos" do
    get recibo_pagos_url
    assert_response :success
  end

  test "should get pagar" do
    get recibo_pagar_url
    assert_response :success
  end
end
