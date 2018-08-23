require 'test_helper'

class AuthorListsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @author_list = author_lists(:one)
  end

  test "should get index" do
    get author_lists_url
    assert_response :success
  end

  test "should get new" do
    get new_author_list_url
    assert_response :success
  end

  test "should create author_list" do
    assert_difference('AuthorList.count') do
      post author_lists_url, params: { author_list: { custcode: @author_list.custcode, dept: @author_list.dept, partcode: @author_list.partcode, priority: @author_list.priority, seq: @author_list.seq, turns: @author_list.turns } }
    end

    assert_redirected_to author_list_url(AuthorList.last)
  end

  test "should show author_list" do
    get author_list_url(@author_list)
    assert_response :success
  end

  test "should get edit" do
    get edit_author_list_url(@author_list)
    assert_response :success
  end

  test "should update author_list" do
    patch author_list_url(@author_list), params: { author_list: { custcode: @author_list.custcode, dept: @author_list.dept, partcode: @author_list.partcode, priority: @author_list.priority, seq: @author_list.seq, turns: @author_list.turns } }
    assert_redirected_to author_list_url(@author_list)
  end

  test "should destroy author_list" do
    assert_difference('AuthorList.count', -1) do
      delete author_list_url(@author_list)
    end

    assert_redirected_to author_lists_url
  end
end
