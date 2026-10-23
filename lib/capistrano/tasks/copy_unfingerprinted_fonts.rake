namespace :deploy do
  desc 'Copy unfingerprinted font files after asset precompile'
  task :copy_unfingerprinted_fonts do
    on roles(:web) do
      # Build script with release_path interpolated by Ruby (safe, server-side)
      script = <<~RUBY
        require 'fileutils'
        release_path = '#{release_path}'
        {
          'font-awesome' => ['fa-solid-900', 'fa-brands-400', 'fa-regular-400'],
          'bootstrap'    => ['glyphicons-halflings-regular']
        }.each do |dir, fonts|
          font_dir = release_path + '/public/assets/' + dir
          fonts.each do |font|
            ['woff2', 'woff', 'ttf', 'eot', 'svg'].each do |ext|
              src = Dir.glob(font_dir + '/' + font + '-*.' + ext).max_by { |f| File.mtime(f) }
              if src
                FileUtils.cp(src, font_dir + '/' + font + '.' + ext)
                puts 'Copied ' + font + '.' + ext
              else
                puts 'Skipped ' + font + '.' + ext
              end
            end
          end
        end
      RUBY

      # Upload script to server temp file & execute
      script_path = "/tmp/copy_fonts_#{Time.now.to_i}.rb"
      upload! StringIO.new(script), script_path
      execute :ruby, script_path
      execute :rm, '-f', script_path
    end
  end
end

after 'deploy:publishing', 'deploy:copy_unfingerprinted_fonts'