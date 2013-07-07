class StaticPagesController < ApplicationController
  def home
    @page_title = 'Welcome to TokenFire!'
  end
end