require 'test_helper'

class DeviceMetricsHistoriesControllerTest < ActionController::TestCase
  setup do
    @device_metrics_history = device_metrics_histories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:device_metrics_histories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create device_metrics_history" do
    assert_difference('DeviceMetricsHistory.count') do
      post :create, device_metrics_history: { AppVersion: @device_metrics_history.AppVersion, Carrier: @device_metrics_history.Carrier, Device_Type: @device_metrics_history.Device_Type, Location: @device_metrics_history.Location, OS: @device_metrics_history.OS, OS_version: @device_metrics_history.OS_version, Resolution: @device_metrics_history.Resolution }
    end

    assert_redirected_to device_metrics_history_path(assigns(:device_metrics_history))
  end

  test "should show device_metrics_history" do
    get :show, id: @device_metrics_history
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @device_metrics_history
    assert_response :success
  end

  test "should update device_metrics_history" do
    put :update, id: @device_metrics_history, device_metrics_history: { AppVersion: @device_metrics_history.AppVersion, Carrier: @device_metrics_history.Carrier, Device_Type: @device_metrics_history.Device_Type, Location: @device_metrics_history.Location, OS: @device_metrics_history.OS, OS_version: @device_metrics_history.OS_version, Resolution: @device_metrics_history.Resolution }
    assert_redirected_to device_metrics_history_path(assigns(:device_metrics_history))
  end

  test "should destroy device_metrics_history" do
    assert_difference('DeviceMetricsHistory.count', -1) do
      delete :destroy, id: @device_metrics_history
    end

    assert_redirected_to device_metrics_histories_path
  end
end
