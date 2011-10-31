require 'xnavi_exceptions'

class Campaign::GiftOrdersController < ApplicationController
  before_filter :authenticated, :except=>[:deliver]
  
  layout 'default'
  
  def index
    @orders = GiftOrder.paginate :conditions=>['member_id = ?', @current_user.id], :order=>'confirmed_at desc, created_at desc', :page=>params[:page]
  end
  
  def show
    @order = @current_user.gift_orders.find params[:id]
  end
  
  def new
    @gift_order = @current_user.gift_orders.build
    @gift_order.payment_method = GiftOrder::PAYMENT_PAY_ON_RECEIVE
    gift = Gift.find params[:gift_id]
    item = @gift_order.gift_order_items.build :gift=>gift
    item.quantity = 1
    @gift_order.deliver_method = item.gift.support_deliver_method
    @gift_order.copy_information_from_member
  end
  
  def create
    begin
      GiftOrder.transaction do 
        @gift_order = @current_user.gift_orders.build params[:gift_order]
        @gift_order.payment_method = GiftOrder::PAYMENT_PAY_ON_RECEIVE
        create_order_items @gift_order
        unless @gift_order.gift_order_items.empty?
          @gift_order.deliver_method = @gift_order.gift_order_items.first.gift.support_deliver_method
          @gift_order.partner = @gift_order.gift_order_items.first.gift.partner
        end
        if @gift_order.save
          @gift_order.gift_order_items.each { |item| item.save! 
            logger.info "after save order item."
          }
          @gift_order.update_total_price!
          @gift_order.affordable_to? @current_user
          redirect_to campaign_gift_order_path(@gift_order)
        else
          render :action => "new"
        end
      end
    rescue ActiveRecord::RecordInvalid
      render :action=> "new"
    rescue XNavi::NoEnoughPointException
      flash.now[:note] = _('You have no enough point to exchange this gift.')
      render :action => "new"
    end
  end
  
  def confirm
    begin
      GiftOrder.transaction do 
        @order = @current_user.gift_orders.find params[:id]
        @order.confirm!
        flash.now['note'] = _('The order is confirmed. We will arrange deliver the goods as soon as possible.')
      end
      send_confirm_mail(@order)
    rescue XNavi::NoEnoughPointException => e
      flash.now[:note] = _('You have no enough point to exchange this gift.')
    end
    render :action => "show"
  end
  
  def edit
    @gift_order = @current_user.gift_orders.find params[:id]
  end
  
  def update
    begin
      @gift_order = @current_user.gift_orders.find params[:id]
      GiftOrder.transaction do 
        create_order_items @gift_order
        logger.info "@gift_order.deliver_method = #{@gift_order.deliver_method}"
        if @gift_order.update_attributes params[:gift_order]
          @gift_order.gift_order_items.each { |item| item.save! }
          @gift_order.update_total_price!
          @gift_order.affordable_to? @current_user
          redirect_to campaign_gift_order_url(@gift_order)
        else
          render :action => "new"
        end
      end
    rescue ActiveRecord::RecordInvalid
      render :action=> "new"
    rescue NoEnoughPointException
      flash.now[:note] = _('You have no enough point to exchange this gift.')
      render :action => "new"
    end
  end

  def deliver
    @order = GiftOrder.find params[:id]
    if @order.can_deliver_by @current_user, @current_partner
      @order.delivered!
    else
      error = _('You have no privilege to do this operation.')
    end
    if @order.visible_to? @current_user, @current_partner
      flash.now[:note] = error
      render :action => "show"
    else
      flash[:note] = error
      redirect_to '/'
    end
  end
  
  private
  def create_order_items(order)
    order.gift_order_items.clear
    if params[:items]
      params[:items].each_pair do |key, value|
        value = value.to_i
        gift = Gift.find key.to_i
        item = order.gift_order_items.build :gift=>gift,
                                 :quantity =>value    
      end
    end
  end
  
  def send_confirm_mail(order)
    GiftOrderMailer.deliver_confirm order
  end
end
