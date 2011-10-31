class MemberPhotosController < ApplicationController
  layout 'default'
  helper 'photos'
  
  def index
    @member = Member.find(params[:member_id])
    @photos = NaviPhoto.paginate_by_uploader_id @member.id,
                               :order => 'created_at',
                               :page=>params[:page]
  end
end
