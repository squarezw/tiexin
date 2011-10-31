module EventsHelper
  def path_to_show_event(event)
    if event.is_a? Promotion
      promotion_path(vendor_type(event.vendor), event.vendor, event)
    else
      event_path(class_name_for_url(event.vendor), event.vendor, event)
    end
  end
  
  def has_event_on(day)
    @events_of_month.find { |event| event.is_on_day?(day) }
  end
  
  def event_name_with_category(event)
    name = h(localized_description(event, :summary))
    name = "[#{h(localized_description(event.event_category, :name))}]&nbsp;#{name}" if event.event_category
    return name
  end
  
  def event_category_select_for(event)
    categories = EventCategory.find(:all)
    categories.delete(EventCategory.find(6)) unless event.new_record?
    categories.collect {|cat| [h(localized_description(cat, :name)), cat.id]}
  end
end
