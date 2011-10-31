module XNavi
  module Privilege
    def self.included(base)
        base.extend(ClassMethods)
    end

    module ClassMethods
      def require_privilege(action, *privilege)
        logger.info "1. set privilege for action #{action}"
        rp = required_privileges
        unless action.nil?
          logger.info "set privilege for action #{action}"
          rp[action.to_sym] = [privilege].flatten
        else
          logger.info "set privilege for 'all_action' "
          rp['all_action'] = [privilege].flatten
        end
        before_filter :check_privilege
      end
      
      def required_privileges
        unless rp = read_inheritable_attribute('required_privileges')
          rp = {}
          write_inheritable_attribute 'required_privileges', rp
        end
        return rp
      end
      
      def required_privileges_for_action(action)
        rp = required_privileges
        if rp.has_key?(action.to_sym)
          rp[action.to_sym]          
        elsif rp.has_key?('all_action')
          rp['all_action']
        else
          []
        end
      end
      
    end
    
    def check_privilege
      logger.info "check privilege for #{action_name}"
      privs = self.class.required_privileges_for_action(action_name)
      return true if privs.empty?
      p = privs.find { |priv| ! @current_user.has_privilege(priv)}
      return true if p.nil?
      render  :file=>File.join(RAILS_ROOT, 'public', '401.html'), :status=>'401'
      false
    end
  end  
end