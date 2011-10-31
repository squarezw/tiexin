class Admin::TabooWordsController < ApplicationController
  before_filter :is_admin
  layout 'admin', :only => [:index] 
  
  def index
    @taboo_words = TabooWord.find(:all, :order => 'word' )
  
  end

  def new 
    @taboo_word = TabooWord.new 
  end

  def edit   
    @taboo_word = TabooWord.find(params[:id])
  end

  def update   
    begin
      @taboo_word = TabooWord.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      alert _('Can not find the taboo word.')
      return
    end
    
    unless @taboo_word.update_attributes(params[:taboo_word])
      alert (@taboo_word.errors.full_messages.join("\n"))
    end
  end

  def create  
    @taboo_word = TabooWord.new(params[:taboo_word])
    unless @taboo_word.save
      render :update do |page|
        page.alert (@taboo_word.errors.full_messages.join("\n"))
      end
    end
  end

  def destroy  
    @taboo_word = TabooWord.find(params[:id])
    @taboo_word.destroy
  end                     
  
  def test                       
    if params[:test_phase].blank?
      render :nothing => true
      return
    end
    @taboo_word = TabooWord.new(params[:taboo_word])
    begin
      if @taboo_word.contained_in(params[:test_phase])
        render :action=>'test_fail'
      else
        render :text=> _('Not contains the taboo word.')
      end
    rescue RegexpError
        render :text=> _('Invalid regular expression.')
    end
  end
end
