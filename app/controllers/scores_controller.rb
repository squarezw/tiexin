class ScoresController < ApplicationController
  before_filter :authenticated, :except => [:show]
  before_filter :find_hot_spot

  def new
    @hot_spot_score = HotSpotScore.new
  end
  
  def update
    
  end
  
  def create
    @hot_spot_score = @hot_spot.hot_spot_scores.build(params[:hot_spot_score])
    @hot_spot_score.member = @current_user
    unless @hot_spot_score.save
      render :update do |page|
        page.replace_html 'form_error', @hot_spot_score.errors.full_messages.join("\n")
        page.call 'dialog.show'
      end
    else
      @hot_spot = HotSpot.find(params[:hot_spot_id])
    end
  end

  private
  def find_hot_spot
    @hot_spot = HotSpot.find(params[:hot_spot_id])
  end
  
end
