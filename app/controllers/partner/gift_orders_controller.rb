require 'dynamic_query'
require 'tempfile'
require 'spreadsheet'

class Partner::GiftOrdersController < ApplicationController
  include Imon::DynamicQuery
  
  before_filter :partner_authenticated
  
  layout  'partner'
  
  def index
    conditions = build_conditions
    @orders = GiftOrder.paginate :conditions=>conditions, :page=>params[:page]
  end
  
  def show
    @order = GiftOrder.find params[:id]
    if @order.partner_id == @current_partner.id
      render :template=>'/campaign/gift_orders/show'      
    else
      flash[:note] = 'You have no privilege to do this operation.'
      redirect_to :action => "index"
    end
  end
  
  def export
    conditions = build_conditions
    @orders = GiftOrder.find :all,:conditions=>conditions
    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet :name=>_('Gift Orders')
    sheet.row(0).concat [_('Order Number'), s_('GiftOrder|Name'), s_('GiftOrder|Status'), s_('Gift Order Summary'),
        s_('Member|Mail'),
        s_('GiftOrder|City'), s_('GiftOrder|Address'), 
        s_('GiftOrder|Post code'), s_('GiftOrder|Phone number'), s_('GiftOrder|Phone number2'), 
        s_('GiftOrder|Certificate type'), s_('GiftOrder|Certificate no'),s_('GiftOrder|Plan fetch date'), 
        s_('GiftOrder|Confirmed at'), s_('GiftOrder|Delivered at'), s_('GiftOrder|Recommender')]
    @orders.each_with_index { |order, i|
      sheet.row(i+1).concat [order.id, order.name, _("gift_order_status|#{order.status}"),
        order.gift_summary, order.member.mail, order.city, order.address, order.post_code, order.phone_number, order.phone_number2, order.certificate_type, order.certificate_no, format_date(order.plan_fetch_date), format_time(order.confirmed_at), format_time(order.delivered_at), order.recommender]
    }
    Tempfile.open('gift_orders') do |tmpfile|
      book.write tmpfile
      send_file tmpfile.path, :filename=>'gift_orders.xls', :type=>'application/excel'
    end
  end
  
  private 
  def build_conditions
    exps = [self.equal(:partner_id, @current_partner.id)]
    exps << self.equal(:id, params[:number]) unless params[:number].nil? or params[:number].empty?
    exps << self.like(:name, params[:name]) unless params[:name].nil? or params[:name].empty?
    exps << self.equal(:status, params[:status]) unless params[:status].nil? or params[:status].empty?
    exps << self.greater_or_equal(:delivered_at, params[:delivered_date_begin]) unless params[:delivered_date_begin].nil? or params[:delivered_date_begin].empty?
    unless params[:delivered_date_end].nil? or params[:delivered_date_end].empty?
      d=Date.parse params[:delivered_date_end]
      exps << self.less(:delivered_at, (d+1.day).to_s)
    end
    return self.and(exps).conditions
  end
  
end
