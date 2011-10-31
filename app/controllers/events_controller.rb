class EventsController < ApplicationController
  before_filter :find_vendor
  before_filter :authenticated, :only=>[:new, :create, :edit, :update]
  before_filter :has_privilege_or_is_owner, :only=>[:new, :create, :edit, :update]
  
  layout 'default', :except=>[:on_date, :show_month]
  
  def index
    if @vendor.is_a? Brand
      redirect_to promotions_url(class_name_for_url(@vendor), @vendor)
      return
    end
    respond_to do |format|
      format.html {
        @events_of_month = @vendor.effective_events_in_month(Date.today)
        @events = @vendor.effective_events(:page=>params[:page])
        render :layout=>false if request.xhr?
      }
      
      format.xml {
        @events = @vendor.effective_events :per_page=>100
        render :layout=>false
      }
    end
  end
  
  def show
    @event = @vendor.events.find params[:id]
  end
  
  def new
    @event = @vendor.events.build
  end
  
  def edit
    @event = @vendor.events.find params[:id]
    @tags_string = @event.tags_string
  end
  
  def update
    @event = @vendor.events.find params[:id]
    if @event.is_a?(Promotion) and @vendor.is_a?(Brand)
      @event.cities.clear
      @event.cities << City.find(params[:cities]) if params[:cities]
    end
    Event.transaction do 
      if @event.update_attributes params[:event]
        save_event_tags @event
        if @event.is_a?(Promotion)
          redirect_to promotion_path(@event.vendor.class.to_s.underscore, @event.vendor, @event)
        else
          redirect_to :action => "show"
        end
      else
        render :action => "edit"
      end
    end
  end
  
  def create
    if params[:is_promotion] and 'true' == params[:is_promotion]
      @event = Promotion.create params[:event]
      @event.vendor = @vendor
    else
      @event = @vendor.events.build params[:event]      
    end
    @event.member = @current_user
    Event.transaction do 
      if @event.save
        save_event_tags @event
        redirect_to :action=>'index'
      else
        render :action => "new"
      end
    end
  end
  
  def on_date
    date = Date.parse params[:date]
    @events = @vendor.effective_events(:page=>params[:page], :on_date=>date)
  end
  
  def show_month
    @date = Date.parse params[:date]
    @events_of_month =  @vendor.effective_events_in_month(@date)
  end
  
  def destroy
    @event = @vendor.events.find params[:id]
    @event.destroy
    redirect_to :action => "index"
  end
  
  private
  def find_vendor
    vendor_class = class_for_name(params[:vendor_type])
    @vendor = vendor_class.send(:find, params[:vendor_id])
  end
  
  def has_privilege_or_is_owner
    return true if @current_user.has_privilege(:manage_events) or @vendor.owner == @current_user
  end
  
  def save_event_tags(event)
    @tags_string = params[:tags]
    event.tags_string= @tags_string
  end
end
