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

class SparcUsersReport < Report
  def self.description
  end

  def default_output_file
    return 'sparc_users_report.csv'
  end

  def assemble_users
    associated = Identity.joins(:project_roles).uniq! {|e| e.id}
    cms = Identity.joins(:catalog_managers).uniq! {|e| e.id}
    sps = Identity.joins(:service_providers).uniq! {|e| e.id}
    sus = Identity.joins(:super_users).uniq! {|e| e.id}

    all_users = (associated + cms + sps + sus).flatten.uniq! {|e| e.id}

    return all_users
  end

  def run
    header = [
      'Name',
      'Email'
    ]

    # Axlsx::Package.new do |p|
    #   p.workbook.add_worksheet(name: 'Report') do |sheet|
    #     sheet.add_row(header)
    #     self.assemble_users.each do |u|
    #       row = [
    #         u.full_name,
    #         u.email
    #       ]
    #       # puts row
    #       sheet.add_row(row)
    #     end
    #   end
    #   puts p.serialize
    #   p.serialize(@output_file)
    # end
    CSV.open(@output_file, 'wb') do |csv|
      csv << header
      self.assemble_users.each do |u|
        row = [
          u.full_name,
          u.email
        ]
          # puts row
        csv << row
      end
    end
  end
end