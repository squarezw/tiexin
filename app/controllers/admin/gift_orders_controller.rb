require 'dynamic_query'
require 'privilege'

class Admin::GiftOrdersController < ApplicationController
  include Imon::DynamicQuery
  include XNavi::Privilege
  
  require_privilege :index, :manage_gift_orders
  require_privilege :show, :manage_gift_orders

  before_filter :authenticated
  before_filter :is_admin
  
  layout 'admin'
  
  def index
    conditions = build_conditions
    @orders = GiftOrder.paginate :conditions=>conditions, :page=>params[:page]
  end
  
  def show
    @order = GiftOrder.find params[:id]
    render :template=>'/campaign/gift_orders/show'    
  end
  
  private 
  def build_conditions
    exps = []
    exps << self.equal(:id, params[:number]) unless params[:number].nil? or params[:number].empty?
    exps << self.like(:name, params[:name]) unless params[:name].nil? or params[:name].empty?
    exps << self.equal(:status, params[:status]) unless params[:status].nil? or params[:status].empty?
    return self.and(exps).conditions
  end
end
