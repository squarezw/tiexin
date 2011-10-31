class BulletinsController < ApplicationController
  
  def index
    @bulletins = Bulletin.paginate :conditions=>['language=? and expire_date >=?', @current_lang.to_s, Time.today.to_date],
                                 :order=>'created_at desc',
                                 :per_page=>20,
                                 :page=>params[:page]

    respond_to do |format|
        format.html {
           render :layout=>'default'
        }
        format.xml {
          render :layout=> false
        }         
      end      
  end

  def show
    @bulletin = Bulletin.find params[:id]
    render :layout=>'simple'
  end
end