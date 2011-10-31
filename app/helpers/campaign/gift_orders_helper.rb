module Campaign::GiftOrdersHelper
  def gift_order_used_point(order)
    result = []
    result << "#{order.used_experience}#{s_('Member|Experience')}" unless order.used_experience == 0
    result << "#{order.used_credit}#{s_('Member|Credit')}" unless order.used_credit == 0
    result << "#{order.cash}#{s_('GiftOrder|Cash')}" unless order.cash == 0
    return result.join('+')
  end
  
  def label_class_for_field(gift_order, field)
    case gift_order.deliver_method
    when GiftOrder::DELIVER_SEND
      return [:city, :address].include?(field) ? 'required' : ''
    when GiftOrder::DELIVER_FETCH
      return [:certificate_type, :certificate_no].include?(field) ? 'required' : ''
    end
  end
end
