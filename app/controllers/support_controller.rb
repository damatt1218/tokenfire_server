class SupportController < ApplicationController
  layout "support"

  def home
    @page_title = 'TokenFire Support - Home'
  end

  def android_sdk_setup
    @page_title = 'TokenFire Support - Android SDK Setup Instructions'
  end
end
