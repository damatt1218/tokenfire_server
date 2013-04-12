class DeviceMetricsHistoriesController < ApplicationController
  # GET /device_metrics_histories
  # GET /device_metrics_histories.json
  def index
    @device_metrics_histories = DeviceMetricsHistory.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @device_metrics_histories }
    end
  end

  # GET /device_metrics_histories/1
  # GET /device_metrics_histories/1.json
  def show
    @device_metrics_history = DeviceMetricsHistory.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @device_metrics_history }
    end
  end

  # GET /device_metrics_histories/new
  # GET /device_metrics_histories/new.json
  def new
    @device_metrics_history = DeviceMetricsHistory.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @device_metrics_history }
    end
  end

  # GET /device_metrics_histories/1/edit
  def edit
    @device_metrics_history = DeviceMetricsHistory.find(params[:id])
  end

  # POST /device_metrics_histories
  # POST /device_metrics_histories.json
  def create
    @device_metrics_history = DeviceMetricsHistory.new(params[:device_metrics_history])

    respond_to do |format|
      if @device_metrics_history.save
        format.html { redirect_to @device_metrics_history, notice: 'Device metrics history was successfully created.' }
        format.json { render json: @device_metrics_history, status: :created, location: @device_metrics_history }
      else
        format.html { render action: "new" }
        format.json { render json: @device_metrics_history.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /device_metrics_histories/1
  # PUT /device_metrics_histories/1.json
  def update
    @device_metrics_history = DeviceMetricsHistory.find(params[:id])

    respond_to do |format|
      if @device_metrics_history.update_attributes(params[:device_metrics_history])
        format.html { redirect_to @device_metrics_history, notice: 'Device metrics history was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @device_metrics_history.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /device_metrics_histories/1
  # DELETE /device_metrics_histories/1.json
  def destroy
    @device_metrics_history = DeviceMetricsHistory.find(params[:id])
    @device_metrics_history.destroy

    respond_to do |format|
      format.html { redirect_to device_metrics_histories_url }
      format.json { head :no_content }
    end
  end
end
