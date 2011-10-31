require 'ipaddr'

class IpSources < ActiveRecord::Base
  untranslate_all
  belongs_to :city
  
  def self.city_for_ip_address(addr, default_city)
    i_addr = IPAddr.new(addr).to_i
    source = self.find :first, :conditions=>['ip_begin <= ? and ip_end >= ?', i_addr, i_addr], :order=>'(ip_end - ip_begin)'
    return default_city if source.nil? or source.city.nil?
    return source.city
  end
end
