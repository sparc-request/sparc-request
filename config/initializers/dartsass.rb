# config/initializers/dartsass.rb
Rails.application.config.dartsass.build_options << " --load-path=#{Rails.root.join('node_modules')}"
