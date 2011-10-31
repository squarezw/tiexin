class OperationLogsController < ApplicationController
  before_filter :authenticated
  before_filter :find_object
  
  layout 'simple'
  
  def index
    if @related_object
      @operation_logs = @related_object.operation_logs
      render :action=>"with_related_object"
    else
      @operation_logs = OperationLog.paginate :order=>'created_at desc',
                                         :page=>params[:page]
      render 
    end
  end
  
  private
  def find_object
    return nil unless params[:object_type] and params[:object_id]
    object_class = params[:object_type].camelize.split("::").inject(Object) { |par, const| par.const_get(const) }
    @related_object = object_class.send(:find, params[:object_id])
  end
end
