class MemberProductsController < ApplicationController
  layout 'default'
  helper 'products'
  
  def index
    @member = Member.find(params[:member_id])
    @products = Product.paginate_by_creator_id @member.id,
                               :order => 'created_at',
                               :page=>params[:page]
  end
end
