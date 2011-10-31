class Admin::ErrorLogsController < ApplicationController
  before_filter :authenticated
  before_filter :is_admin
  layout 'default'
  
  def index
    @error_logs = ErrorLog.paginate :order=>'created_at desc', :per_page=>20, :page=>params[:page]
  end
  
  def show
    @error_log = ErrorLog.find params[:id]
  end
end
