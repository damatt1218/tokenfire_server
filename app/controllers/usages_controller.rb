class UsagesController < ApplicationController

  def show
    @application = App.find(params[:app_id])
  end

end