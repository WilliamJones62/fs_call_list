require 'test_helper'

class OnSpecialsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @on_special = on_specials(:one)
  end

  test "should get index" do
    get on_specials_url
    assert_response :success
  end

  test "should get new" do
    get new_on_special_url
    assert_response :success
  end

  test "should create on_special" do
    assert_difference('OnSpecial.count') do
      post on_specials_url, params: { on_special: { customer: @on_special.customer, onspecials_end: @on_special.onspecials_end, onspecials_start: @on_special.onspecials_start, part: @on_special.part } }
    end

    assert_redirected_to on_special_url(OnSpecial.last)
  end

  test "should show on_special" do
    get on_special_url(@on_special)
    assert_response :success
  end

  test "should get edit" do
    get edit_on_special_url(@on_special)
    assert_response :success
  end

  test "should update on_special" do
    patch on_special_url(@on_special), params: { on_special: { customer: @on_special.customer, onspecials_end: @on_special.onspecials_end, onspecials_start: @on_special.onspecials_start, part: @on_special.part } }
    assert_redirected_to on_special_url(@on_special)
  end

  test "should destroy on_special" do
    assert_difference('OnSpecial.count', -1) do
      delete on_special_url(@on_special)
    end

    assert_redirected_to on_specials_url
  end
end
