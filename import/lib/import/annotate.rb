def annotate(msg)
  begin
    yield
  rescue Exception
    if $!.message.frozen? then
      message = $!.message + "\n  while #{msg}"
      raise $!.class.new(message), $!.backtrace
    else
      $!.message << "\n  while #{msg}"
      raise $!
    end
  end
end

