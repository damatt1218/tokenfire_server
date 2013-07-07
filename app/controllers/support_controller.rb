class SupportController < ApplicationController
  def home
    @page_title = 'TokenFire Support - Home'
  end

  def android_sdk_setup
    @page_title = 'TokenFire Support - Android SDK Setup Instructions'
  end

  def contact_us
    @page_title = 'TokenFire - Contact Us!'
  end

  def about_us
    @page_title = 'TokenFire - About Us'
  end

  def dev_terms
    @page_title = 'TokenFire - Developer Terms and Agreement'
  end
end
