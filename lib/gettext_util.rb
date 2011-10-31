module XNavi
  module GetTextUtil
    def change_locale_temporary(locale)
      old_locale = Locale.current
      set_locale locale
      yield
      set_locale old_locale
    end
  end
end