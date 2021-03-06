require 'test_helper'

class LogFilesControllerTest < ActionController::TestCase
  setup do
  end

  test 'should get index' do
    get :index
    assert_response :success
    assert_not_nil assigns(:log_files)
  end

  test 'should get new' do
    get :new
    assert_response :success
  end

  test 'should create log_file' do
    assert_difference('LogFile.count') do
      post :create, log_file: {}
    end

    assert_redirected_to log_file_path(assigns(:log_file))
  end
end
