def legacy_parse_date(s)
  case s 
  when nil, ''
    return nil

  when /(\d+)-(\d+)-(\d+)/
    yyyy = $1.to_i
    mm = $2.to_i
    dd = $3.to_i

    # workaround for a bug in the time picker
    # this isn't a perfect workaround
    if mm < 3 and yyyy <= 2012 then
      mm += 10
    elsif mm == 0 then
      mm += 10
    end

    return Date.new(yyyy, mm, dd)

  else
    return Date.parse(s)
  end
end

