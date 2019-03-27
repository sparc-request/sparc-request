# Copyright © 2011-2019 MUSC Foundation for Research Development
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
  def prompt(*args)
    print(*args)
    STDIN.gets.strip
  end

  puts "The SPARCRequest code base will be updated with the following copyright:  'Copyright © 2011-___ MUSC Foundation for Research Development', this script requires the year currently in the code base and the year that you wish to update it to."

  copyright_year_needing_to_be_updated = prompt("Please enter the year needing to be updated (the year currently in the code base):  ")
  updated_copyright_year = prompt("Please enter the year you want the code base to be updated to:  ")

  files_with_more_than_one_copyright = []
  files_updated = []
  empty_files = []
  files_updated_to_have_a_copyright = []
  file_with_other_variation_of_copyright_updated = []

  Dir.glob(Rails.root + '**/*{.rb,.haml,.coffee,.example,.rake,.ru,.js,.erb,.scss,.sass,.css}') do |file|

    ### Query that most files will have ###
    query = "Copyright © 2011-#{copyright_year_needing_to_be_updated} MUSC Foundation for Research Development"
    ### Query with some other copyright variation ###
    other_variation_of_query = "Copyright ©"

    ### Guard against empty files ###
    if File.readlines(file).present?

      ### Does the file contain any of these copyright queries? ###
      query_size =  readlines_with_proper_encoding(file, query).size
      other_variation_of_query_size = readlines_with_proper_encoding(file, other_variation_of_query).size

      if query_size > 0
        if query_size == 1
          write_to_file(file, query, false, updated_copyright_year)
          files_updated << file
        else # More than one copyright, needs to be taken care of manually
          files_with_more_than_one_copyright << file
        end
      elsif other_variation_of_query_size > 0
        if other_variation_of_query_size == 1

          index_of_copyright = readlines_with_proper_encoding(file, other_variation_of_query).first.index('Copyright')
          other_variation_of_query = readlines_with_proper_encoding(file, other_variation_of_query).first[index_of_copyright..-1]
          write_to_file(file, other_variation_of_query, true, updated_copyright_year)
          files_updated << file

          file_with_other_variation_of_copyright_updated << file
        else  # More than one copyright, needs to be taken care of manually
          files_with_more_than_one_copyright << file
        end
      else # File doesn't have a copyright at all and needs one added
        header = "# Copyright © 2011-#{updated_copyright_year} MUSC Foundation for Research Development~\n"
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
        files_updated_to_have_a_copyright << file
      end
    else # File empty
      empty_files << file
    end
  end
  ### SUMMARY ###
  puts "*" * 50
  puts "<<<<< SUMMARY >>>>>"
  puts "*" * 50
  puts "The following #{files_updated_to_have_a_copyright.count} files had copyrights added to them:  "
  puts "*" * 50
  puts "*" * 50
  puts files_updated_to_have_a_copyright
  puts "*" * 50
  puts "*" * 50
  puts "The following #{files_updated.count} files have had their copyrights updated:  "
  puts "*" * 50
  puts "*" * 50
  puts files_updated
  puts "*" * 50
  puts "*" * 50
  puts "<<<<< ACTION REQUIRED: >>>>>"
  puts "These #{files_with_more_than_one_copyright.count} files have more than one copyright and need to be manually changed:  "
  puts "*" * 50
  puts "*" * 50
  puts files_with_more_than_one_copyright
  puts "*" * 50
  puts "*" * 50
  puts "The following #{empty_files.count} files are empty:  "
  puts empty_files
  ### END SUMMARY ###
end

def find_postfix(file)
  if File.extname(file) == '.erb'
    postfix = "%>\n"
  elsif File.extname(file) == '.css' || File.extname(file) == '.sass' || File.extname(file) == '.scss'
    postfix = "*/\n"
  else
    postfix = "\n"
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

def write_to_file(file, query, other_variation, updated_copyright_year)
  postfix = find_postfix(file)

  updated_copyright = other_variation ? "Copyright © 2011-#{updated_copyright_year} MUSC Foundation for Research Development#{postfix}" : "Copyright © 2011-#{updated_copyright_year} MUSC Foundation for Research Development"

  code_file = File.readlines(file).first.valid_encoding? ? File.read(file) : File.read(file).encode("UTF-8", "Windows-1252")

  updated_code_file = other_variation ? code_file.sub(query, updated_copyright) : code_file.gsub(/#{query}/, updated_copyright)

  File.open(file, 'w') { |file| file.write(updated_code_file) }
end

def readlines_with_proper_encoding(file, query)
  File.readlines(file).first.valid_encoding? ? File.readlines(file).grep(/#{query}/) : [File.read(file).encode("UTF-8", "Windows-1252")].grep(/#{query}/)
end
