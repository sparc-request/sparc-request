class Sprockets::DirectiveProcessor
  def process_depend_on_config_directive(file)
    path = File.expand_path(file, "#{Rails.root}/config")
    context.depend_on(path)
  end
end

