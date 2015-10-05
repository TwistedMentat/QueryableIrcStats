require 'test_helper'

class HostnamesControllerTest < ActionController::TestCase
  setup do
    @hostname = hostnames(:hostname_one)
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:hostnames)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should show hostname' do
    get :show, id: @hostname
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @hostname
    assert_response :success
  end

  test 'should update hostname' do
    put :update, id: @hostname, hostname: { domain_name: @hostname.domain_name }
    assert_redirected_to hostname_path(assigns(:hostname))
  end
end
