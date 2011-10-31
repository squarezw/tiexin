class LanguageController < ApplicationController

  def select_lang   
      lang = params[:lang]
      lang = 'zh_cn' unless lang =~ /(en)|(zh_cn)|(jp)/
      cookies['lang'] = lang
      set_locale lang
      redirect_to city_path(@current_city)
  end
end