require 'test_helper'

class PromocodeControllerTest < ActionDispatch::IntegrationTest
  test "should get activate" do
    get promocode_activate_url
    assert_response :success
  end

end
