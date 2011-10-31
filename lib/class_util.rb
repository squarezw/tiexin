module Imon
  module Utilities
    def class_for_name(name)
      return name.camelize.split("::").inject(Object) { |par, const| par.const_get(const) }
    end
  end
end
