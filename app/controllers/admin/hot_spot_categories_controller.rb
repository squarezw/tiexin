require 'imon_exception'

class Admin::HotSpotCategoriesController < ApplicationController    
  before_filter :is_admin
  layout 'admin', :only=>[:index]
  helper :hot_spot_categories
  
  def index
    @roots = HotSpotCategory.roots
  end                                 
  
  def show
    edit
    render :action => "edit"
  end
  
  def new
    if params[:parent_id]
      parent = HotSpotCategory.find(params[:parent_id])
      @category = parent.children.build()
      @category.order_weight = parent.order_weight
    else
      @category = HotSpotCategory.new
    end
  end       
  
  def create
    if params[:category][:parent_id]
      begin
        parent = HotSpotCategory.find  params[:category][:parent_id]
      rescue ActiveRecord::RecordNotFound
        logger.warn "Can not find category #{params[:category][:parent_id]}"
        respond_to_parent do
          render :update do |page|
            page.alert _('Can not find parent category.')
            page.replace_html 'div_category_form', ''
          end
        end
        return
      end
      @category = parent.children.build(params[:category])
    else
      @category = HotSpotCategory.new(params[:category])
    end  
      
    if @category.save
      responds_to_parent do 
        render :layout=>false
      end
    else
      responds_to_parent do 
        render :update do |page|
          page.alert (@category.errors.full_messages.join("\n"))
        end
      end
    end
  end       
  
  def edit
    @category = HotSpotCategory.find(params[:id])
  end                      
  
  def update
    @category = HotSpotCategory.find(params[:id])
    if @category.update_attributes(params[:category])
      if params[:apply_to_children_categories]
        HotSpotCategory.update_all(["order_weight = ?", @category.order_weight],["id in (?)",@category.id_of_all_children_include_self])
      end
      respond_to_parent do 
        render :layout=>false
      end
    else
      respond_to_parent do 
        render :update do |page|
          page.alert (@category.errors.full_messages.join("\n"))
        end
      end
    end
  end
  
  def destroy
    @category = HotSpotCategory.find(params[:id])
    begin
      @category.destroy
    rescue Imon::CantDestroyException => e
      render :update do |page|
        page.alert _('You can not delete this %{obj_name} now.') % {:obj_name=>_('hot spot category')}
      end
    end
  end
  
  def merge_or_move
    @category = HotSpotCategory.find(params[:id])
    new_parent_id = find_hot_spot_category(params[:hot_spot_category_root_id],params[:hot_spot_category_children_id]).id
    #new_parent_id = params[:category][:parent_id].to_i

    if params[:MorM] == "move" && new_parent_id != 0
      unless @category.id_of_all_children_include_self.include?new_parent_id
          unless @category.update_attribute(:parent_id,new_parent_id)
            respond_to_parent do 
              render :update do |page|
                page.alert (@category.errors.full_messages.join("\n"))
              end
            end
          end
      else
          render :update do |page|
            page.alert _("You can not move to children or self" )
        end
      end
      
    elsif params[:MorM] == "merge" && new_parent_id != 0
      unless @category.id_of_all_children_include_self.include?new_parent_id
          HotSpot.update_all(["hot_spot_category_id = ?",new_parent_id],["hot_spot_category_id = ?",@category.id])
          HotSpotCategory.update_all(["parent_id = ?",new_parent_id],["parent_id = ?",@category.id])
          HotSpotCategory.destroy(@category.id)
      else
          render :update do |page|
            page.alert _("You can not move to children or self" )
          end
      end
    else
      render :update do |page|
         page.call "merge_or_move_submit_check",'merge_move_form','MorM'
      end
    end
    
  end
  
  def category_tree
    @roots = HotSpotCategory.roots
  end
  
end
