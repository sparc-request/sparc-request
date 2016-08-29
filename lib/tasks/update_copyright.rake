# Copyright © 2011-2016 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

task update_copyright: :environment do
  Dir.glob(Rails.root + '**/*{.rb,.haml,.coffee,.example,.rake,.ru,.js,.erb,.scss,.sass,.css}') do |file|
    query = "Copyright © 2011-2016 MUSC Foundation for Research Development"
    updated_copyright = "Copyright © 2011-2016 MUSC Foundation for Research Development"
    if File.readlines(file).grep(/#{query}/).size > 0
      code_file = File.read(file)
      updated_code_file = code_file.gsub(/#{query}/, updated_copyright)

      File.open(file, 'w') { |file| file.write(updated_code_file) }
    elsif File.readlines(file).grep(/#{query}/).size < 0
      header = "# Copyright © 2011-2016 MUSC Foundation for Research Development~\n"
      header += "# All rights reserved.~\n\n"
      header += "# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~\n\n"
      header += "# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~\n\n"
      header += "# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~\n"
      header += "# disclaimer in the documentation and/or other materials provided with the distribution.~\n\n"
      header += "# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~\n"
      header += "# derived from this software without specific prior written permission.~\n\n"
      header += "# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS \"AS IS\" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~\n"
      header += "# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~\n"
      header += "# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~\n"
      header += "# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~\n"
      header += "# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~\n"
      header += "# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~\n\n"
      different_formats = [".js", ".scss", ".sass"]
      prefix = '#'
      postfix = '~'
      if File.extname(file) == ".haml"
        prefix = '-#'
      elsif different_formats.include? File.extname(file)
        prefix = '//'
      elsif File.extname(file) == '.erb'
        prefix = '<%#'
        postfix = '%>'
      elsif File.extname(file) == '.css'
        prefix = '/*'
        postfix = '*/'
      end
      file_prepend(file, header, prefix, postfix)
    end
  end
end
def file_prepend(file, str, prefix, postfix)
  f = File.open(file, "r+")
  lines = f.readlines
  f.close

  str = str.gsub(/#/, prefix)
  str = str.gsub(/~/, postfix)

  lines = [str] + lines

  output = File.new(file, "w")
  lines.each { |line| output.write line }
  output.close
end
