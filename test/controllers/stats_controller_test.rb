require "test_helper"

class StatsControllerTest < ActionDispatch::IntegrationTest
  test "should get monthly_comparison" do
    get stats_monthly_comparison_url
    assert_response :success
  end
end
