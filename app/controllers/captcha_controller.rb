class CaptchaController < ApplicationController
  after_filter :write_access_log, :except=>:index
  def index
    generate_captcha
    send_data @captcha.code_img, 
              :type=>'image/jpeg',
              :disposition=>'inline'
  end
end

