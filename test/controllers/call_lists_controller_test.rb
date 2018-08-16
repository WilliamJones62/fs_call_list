require 'test_helper'

class CallListsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @call_list = call_lists(:one)
  end

  test "should get index" do
    get call_lists_url
    assert_response :success
  end

  test "should get new" do
    get new_call_list_url
    assert_response :success
  end

  test "should create call_list" do
    assert_difference('CallList.count') do
      post call_lists_url, params: { call_list: { callback: @call_list.callback, callback_date: @call_list.callback_date, callday: @call_list.callday, called: @call_list.called, contact: @call_list.contact, contact_method: @call_list.contact_method, custcode: @call_list.custcode, custname: @call_list.custname, date_called: @call_list.date_called, date_ordered: @call_list.date_ordered, email: @call_list.email, isr: @call_list.isr, main_phone: @call_list.main_phone, notes: @call_list.notes, ordered: @call_list.ordered, phone: @call_list.phone, rep: @call_list.rep, selling: @call_list.selling, website: @call_list.website } }
    end

    assert_redirected_to call_list_url(CallList.last)
  end

  test "should show call_list" do
    get call_list_url(@call_list)
    assert_response :success
  end

  test "should get edit" do
    get edit_call_list_url(@call_list)
    assert_response :success
  end

  test "should update call_list" do
    patch call_list_url(@call_list), params: { call_list: { callback: @call_list.callback, callback_date: @call_list.callback_date, callday: @call_list.callday, called: @call_list.called, contact: @call_list.contact, contact_method: @call_list.contact_method, custcode: @call_list.custcode, custname: @call_list.custname, date_called: @call_list.date_called, date_ordered: @call_list.date_ordered, email: @call_list.email, isr: @call_list.isr, main_phone: @call_list.main_phone, notes: @call_list.notes, ordered: @call_list.ordered, phone: @call_list.phone, rep: @call_list.rep, selling: @call_list.selling, website: @call_list.website } }
    assert_redirected_to call_list_url(@call_list)
  end

  test "should destroy call_list" do
    assert_difference('CallList.count', -1) do
      delete call_list_url(@call_list)
    end

    assert_redirected_to call_lists_url
  end
end
