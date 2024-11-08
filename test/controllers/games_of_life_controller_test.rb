require "test_helper"

class GamesOfLifeControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test "should process valid state file and return a turbo stream response" do
    ok_state_expect_horizontal = fixture_file_upload("ok_state_expect_horizontal.txt", "text/plain")
    user = users(:one)
    sign_in user
    post post_file_gol_url, params: { state_file: ok_state_expect_horizontal }, headers: { "Accept" => "text/vnd.turbo-stream.html" }
    assert_response :success
  end

  test "should redirect if not authenticated" do
    ok_state_expect_horizontal = fixture_file_upload("ok_state_expect_horizontal.txt", "text/plain")
    post post_file_gol_url, params: { state_file: ok_state_expect_horizontal }
    assert_response :redirect
  end
end
