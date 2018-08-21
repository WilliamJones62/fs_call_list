require 'test_helper'

class DontSellsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @dont_sell = dont_sells(:one)
  end

  test "should get index" do
    get dont_sells_url
    assert_response :success
  end

  test "should get new" do
    get new_dont_sell_url
    assert_response :success
  end

  test "should create dont_sell" do
    assert_difference('DontSell.count') do
      post dont_sells_url, params: { dont_sell: { customer: @dont_sell.customer, dontcalls_end: @dont_sell.dontcalls_end, dontcalls_start: @dont_sell.dontcalls_start, part: @dont_sell.part } }
    end

    assert_redirected_to dont_sell_url(DontSell.last)
  end

  test "should show dont_sell" do
    get dont_sell_url(@dont_sell)
    assert_response :success
  end

  test "should get edit" do
    get edit_dont_sell_url(@dont_sell)
    assert_response :success
  end

  test "should update dont_sell" do
    patch dont_sell_url(@dont_sell), params: { dont_sell: { customer: @dont_sell.customer, dontcalls_end: @dont_sell.dontcalls_end, dontcalls_start: @dont_sell.dontcalls_start, part: @dont_sell.part } }
    assert_redirected_to dont_sell_url(@dont_sell)
  end

  test "should destroy dont_sell" do
    assert_difference('DontSell.count', -1) do
      delete dont_sell_url(@dont_sell)
    end

    assert_redirected_to dont_sells_url
  end
end
