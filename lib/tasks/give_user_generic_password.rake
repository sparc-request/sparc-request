# Copyright © 2011-2016 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

namespace :data do
  desc "Give user a generic password"
  task :give_user_generic_password => :environment do
    def header
      [
        "identity_id"
      ]
    end

    def prompt(*args)
      print(*args)
      STDIN.gets.strip
    end

    def get_file(error=false)
      puts "No import file specified or the file specified does not exist in db/imports" if error
      file = prompt "Please specify the file name to import from db/imports (must be a CSV, see db/imports/example.csv for formatting): "
      puts ""
      continue = prompt "Password of all users will be changed!  Press any key to continue or CTRL-C to exit"
      puts ""
      while file.blank? or not File.exists?(Rails.root.join("db", "imports", file))
        file = get_file(true)
      end

      file
    end

    begin
      file = get_file
      input_file = Rails.root.join('db', 'imports', file)
      count = 0
      CSV.foreach(input_file, :headers => true, :encoding => 'windows-1251:utf-8') do |row|
        id = row["identity_id"]
        i = Identity.find(id.to_i)
        password = Devise.friendly_token
        i.update_attributes(password: password,
                            password_confirmation: password)
        print i.ldap_uid
        print "  -  "
        puts password
        count += 1
      end
      puts ""
      puts "There were #{count} passwords successfully reset."
      puts ""
    end
  end
end
