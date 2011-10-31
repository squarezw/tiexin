class Admin::DataEventsController < ApplicationController
  layout 'default'
  before_filter :find_or_initialize, :except => [:index]
  helper 'hot_spot_categories'

  auto_complete_for :hot_spot, :name_zh_cn, :limit => 10

  def index
    @daq_evnets = DaqEvent.paginate :conditions => "published is not true",:order => " id desc",:page => params[:page],:per_page => 10
  end

  def destroy
    @daq_evnet.destroy
    flash[:note]=_("'%{name}' has been deleted.") % {:name=>@daq_evnet.event_name}
    redirect_to admin_data_events_path+"?page=#{params[:page]}"
  end

  def related_hot_spots
    daq_event_id = params[:event_id]
    @daq_event = DaqEvent.find(daq_event_id)
    conditions = []
    if params[:hot_spot] and params[:hot_spot][:name_zh_cn]
      name_zh_cn = params[:hot_spot][:name_zh_cn]
      conditions = ["name_zh_cn like ?", "%#{name_zh_cn}%"]
      @keyword_exp = name_zh_cn
    end
    @hot_spots = HotSpot.paginate :conditions=>conditions,
                                 :order=>'updated_at desc, created_at desc',
                                 :per_page=>10,
                                 :page=>params[:page]
    render :layout=>false

  end

  def insert_related
    daq_event_id = params[:daq_event_id].to_i
    hot_spot_id = params[:hot_spot_id].to_i
    @daq_event = DaqEvent.find(daq_event_id)
    
    @event = Event.new

    @event.vendor_type = "HotSpot"
    @event.vendor_id = hot_spot_id
    @event.member_id = @current_user.id
    @event.summary_zh_cn = @daq_event.event_name
    @event.content_zh_cn = @daq_event.event_content
    @event.begin_date = @daq_event.start_date
    @event.end_date = @daq_event.end_date
    if File.exist?("#{RAILS_ROOT}/public/images/#{@daq_event.picture}")
      pic = File.open("#{RAILS_ROOT}/public/images/#{@daq_event.picture}")
      @event.banner = pic
      @event.post = pic
    end
    @event.event_category_id = 1

    if @event.save and @daq_event.published
       render :update do |page|
           page.call 'panel.hide'
           page.alert _('Promotion was successfully created.')
           page.call 'new Effect.BlindUp',"event_#{@daq_event.id}"
       end
    else
      render  :update do |page|
        page.replace_html 'form_error', @event.errors.full_messages.join("\n")
        page.call 'dialog.show'
      end
    end

  end

  private
  def find_or_initialize
    @daq_evnet = params[:id] ? DaqEvent.find(params[:id]) : DaqEvent.new
  end
end
