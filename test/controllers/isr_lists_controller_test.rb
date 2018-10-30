require 'test_helper'

class IsrListsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @isr_list = isr_lists(:one)
  end

  test "should get index" do
    get isr_lists_url
    assert_response :success
  end

  test "should get new" do
    get new_isr_list_url
    assert_response :success
  end

  test "should create isr_list" do
    assert_difference('IsrList.count') do
      post isr_lists_url, params: { isr_list: { name: @isr_list.name } }
    end

    assert_redirected_to isr_list_url(IsrList.last)
  end

  test "should show isr_list" do
    get isr_list_url(@isr_list)
    assert_response :success
  end

  test "should get edit" do
    get edit_isr_list_url(@isr_list)
    assert_response :success
  end

  test "should update isr_list" do
    patch isr_list_url(@isr_list), params: { isr_list: { name: @isr_list.name } }
    assert_redirected_to isr_list_url(@isr_list)
  end

  test "should destroy isr_list" do
    assert_difference('IsrList.count', -1) do
      delete isr_list_url(@isr_list)
    end

    assert_redirected_to isr_lists_url
  end
end
