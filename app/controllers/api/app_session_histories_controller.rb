class AppSessionHistoriesController < ApplicationController
  # GET /app_session_histories
  # GET /app_session_histories.json
  def index
    @app_session_histories = AppSessionHistory.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @app_session_histories }
    end
  end

  # GET /app_session_histories/1
  # GET /app_session_histories/1.json
  def show
    @app_session_history = AppSessionHistory.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @app_session_history }
    end
  end

  # GET /app_session_histories/new
  # GET /app_session_histories/new.json
  def new
    @app_session_history = AppSessionHistory.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @app_session_history }
    end
  end

  # GET /app_session_histories/1/edit
  def edit
    @app_session_history = AppSessionHistory.find(params[:id])
  end

  # POST /app_session_histories
  # POST /app_session_histories.json
  def create
    @app_session_history = AppSessionHistory.new(params[:app_session_history])

    respond_to do |format|
      if @app_session_history.save
        format.html { redirect_to @app_session_history, notice: 'App session history was successfully created.' }
        format.json { render json: @app_session_history, status: :created, location: @app_session_history }
      else
        format.html { render action: "new" }
        format.json { render json: @app_session_history.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /app_session_histories/1
  # PUT /app_session_histories/1.json
  def update
    @app_session_history = AppSessionHistory.find(params[:id])

    respond_to do |format|
      if @app_session_history.update_attributes(params[:app_session_history])
        format.html { redirect_to @app_session_history, notice: 'App session history was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @app_session_history.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /app_session_histories/1
  # DELETE /app_session_histories/1.json
  def destroy
    @app_session_history = AppSessionHistory.find(params[:id])
    @app_session_history.destroy

    respond_to do |format|
      format.html { redirect_to app_session_histories_url }
      format.json { head :no_content }
    end
  end
end
