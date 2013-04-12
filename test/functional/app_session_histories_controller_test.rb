require 'test_helper'

class AppSessionHistoriesControllerTest < ActionController::TestCase
  setup do
    @app_session_history = app_session_histories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:app_session_histories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create app_session_history" do
    assert_difference('AppSessionHistory.count') do
      post :create, app_session_history: { SessionDuration: @app_session_history.SessionDuration, eventTimeStamp: @app_session_history.eventTimeStamp, sdkVersion: @app_session_history.sdkVersion }
    end

    assert_redirected_to app_session_history_path(assigns(:app_session_history))
  end

  test "should show app_session_history" do
    get :show, id: @app_session_history
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @app_session_history
    assert_response :success
  end

  test "should update app_session_history" do
    put :update, id: @app_session_history, app_session_history: { SessionDuration: @app_session_history.SessionDuration, eventTimeStamp: @app_session_history.eventTimeStamp, sdkVersion: @app_session_history.sdkVersion }
    assert_redirected_to app_session_history_path(assigns(:app_session_history))
  end

  test "should destroy app_session_history" do
    assert_difference('AppSessionHistory.count', -1) do
      delete :destroy, id: @app_session_history
    end

    assert_redirected_to app_session_histories_path
  end
end
