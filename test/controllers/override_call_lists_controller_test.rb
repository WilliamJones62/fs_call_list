require 'test_helper'

class OverrideCallListsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @override_call_list = override_call_lists(:one)
  end

  test "should get index" do
    get override_call_lists_url
    assert_response :success
  end

  test "should get new" do
    get new_override_call_list_url
    assert_response :success
  end

  test "should create override_call_list" do
    assert_difference('OverrideCallList.count') do
      post override_call_lists_url, params: { override_call_list: { callback: @override_call_list.callback, callback_date: @override_call_list.callback_date, callday: @override_call_list.callday, called: @override_call_list.called, contact: @override_call_list.contact, contact_method: @override_call_list.contact_method, custcode: @override_call_list.custcode, custname: @override_call_list.custname, date_called: @override_call_list.date_called, date_ordered: @override_call_list.date_ordered, email: @override_call_list.email, isr: @override_call_list.isr, main_phone: @override_call_list.main_phone, notes: @override_call_list.notes, ordered: @override_call_list.ordered, override_end: @override_call_list.override_end, override_start: @override_call_list.override_start, phone: @override_call_list.phone, rep: @override_call_list.rep, selling: @override_call_list.selling, website: @override_call_list.website, window: @override_call_list.window } }
    end

    assert_redirected_to override_call_list_url(OverrideCallList.last)
  end

  test "should show override_call_list" do
    get override_call_list_url(@override_call_list)
    assert_response :success
  end

  test "should get edit" do
    get edit_override_call_list_url(@override_call_list)
    assert_response :success
  end

  test "should update override_call_list" do
    patch override_call_list_url(@override_call_list), params: { override_call_list: { callback: @override_call_list.callback, callback_date: @override_call_list.callback_date, callday: @override_call_list.callday, called: @override_call_list.called, contact: @override_call_list.contact, contact_method: @override_call_list.contact_method, custcode: @override_call_list.custcode, custname: @override_call_list.custname, date_called: @override_call_list.date_called, date_ordered: @override_call_list.date_ordered, email: @override_call_list.email, isr: @override_call_list.isr, main_phone: @override_call_list.main_phone, notes: @override_call_list.notes, ordered: @override_call_list.ordered, override_end: @override_call_list.override_end, override_start: @override_call_list.override_start, phone: @override_call_list.phone, rep: @override_call_list.rep, selling: @override_call_list.selling, website: @override_call_list.website, window: @override_call_list.window } }
    assert_redirected_to override_call_list_url(@override_call_list)
  end

  test "should destroy override_call_list" do
    assert_difference('OverrideCallList.count', -1) do
      delete override_call_list_url(@override_call_list)
    end

    assert_redirected_to override_call_lists_url
  end
end
