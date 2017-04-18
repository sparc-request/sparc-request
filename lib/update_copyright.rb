Dir.glob('/Users/williamholt/projects/hssc/sparc-request/**/*{.rb,.haml,.coffee,.example,.rake,.ru,.js,.erb,.scss,.sass,.css}') do |file|
  query = "Copyright © 2011 MUSC Foundation for Research Development"
  updated_copyright = "Copyright © 2011-2016 MUSC Foundation for Research Development."
  if File.read(file) =~ /#{query}/
    code_file = File.read(file)
    updated_code_file = code_file.gsub(/#{query}/, updated_copyright)

    File.open(file, 'w') { |file| file.write(updated_code_file) }
  else
    f = File.open(file, 'r+')
    lines = f.readlines
    f.close
    different_formats = [".js", ".scss", ".sass"]
    if File.extname(file) == ".haml"
      new_copyright = "-# Copyright © 2011-2016 MUSC Foundation for Research Development.\n-# All rights reserved.\n"
    elsif different_formats.include? File.extname(file)
      new_copyright = "// Copyright © 2011-2016 MUSC Foundation for Research Development.\n// All rights reserved.\n"
    elsif File.extname(file) == '.erb'
      new_copyright = "<%# Copyright © 2011-2016 MUSC Foundation for Research Development.%>\n<%# All rights reserved.%>\n"
    elsif File.extname(file) == '.css'
      new_copyright = "/* Copyright © 2011-2016 MUSC Foundation for Research Development.*/\n/* All rights reserved.*/"
    else
      new_copyright = "# Copyright © 2011-2016 MUSC Foundation for Research Development.\n# All rights reserved.\n"
    end
    lines = [new_copyright] + lines

    output = File.new(file, 'w')
    lines.each { |line| output.write line }
    output.close
  end
end
