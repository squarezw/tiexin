class MemberRevisesController < ApplicationController
  layout 'default'
  def index
    @member = Member.find(params[:member_id])
    @revises = Revise.paginate_by_member_id @member.id,
                               :order => 'created_at',
                               :per_page=>10,
                               :page=>params[:page]
  end
end
