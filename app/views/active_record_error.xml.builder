xml.result :code=>207 do 
  errors = @errors.localize_error_messages
  errors.each_key { |field| 
    errors[field].each { |msg|
      xml.error msg, :field=>_(field)
    }
  }
end