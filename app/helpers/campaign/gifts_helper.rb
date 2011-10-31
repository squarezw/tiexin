module Campaign::GiftsHelper
  def gift_price(gift)
    price = []
    price << "#{gift.experience}#{_('Member|Experience')}" if gift.experience > 0
    price << "#{gift.credit}#{_('Member|Credit')}" if gift.credit > 0
    price << "#{gift.cash}#{_('Gift|Cash')}" if gift.cash > 0
    return price.join('+')
  end
end
