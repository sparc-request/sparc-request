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

module EmailHelpers
  
  def protocol_information_table
    expect(@mail).to have_xpath "//table//strong[text()='Study Information']"
    expect(@mail).to have_xpath "//th[text()='Study ID']/following-sibling::td[text()='#{@protocol.id}']"
    expect(@mail).to have_xpath "//th[text()='Short Title']/following-sibling::td[text()='#{@protocol.short_title}']"
    expect(@mail).to have_xpath "//th[text()='Study Title']/following-sibling::td[text()='#{@protocol.title}']"
    expect(@mail).to have_xpath "//th[text()='Sponsor Name']/following-sibling::td[text()='#{@protocol.sponsor_name}']"
    expect(@mail).to have_xpath "//th[text()='Funding Source']/following-sibling::td[text()='#{@protocol.funding_source.capitalize}']"
  end

  def user_information_table_with_epic_col(delete=false)
    expect(@mail).to have_xpath "//table//strong[text()='User Information']"
    expect(@mail).to have_xpath "//th[text()='User Modification']/following-sibling::th[text()='Contact Information']/following-sibling::th[text()='Role']/following-sibling::th[text()='SPARC Proxy Rights']/following-sibling::th[text()='Epic Access']"

    if delete
      [modified_identity.full_name, modified_identity.email, modified_identity.project_roles.first.role.upcase, modified_identity.project_roles.first.display_rights, modified_identity.project_roles.first.epic_access ? 'Yes' : 'No'].each do |text|
        expect(@mail).to have_selector('td del', text: text)
      end
    else
      expect(@mail).to_not have_selector('td del')
    end
  end

  def user_information_table_without_epic_col(delete=false)
    expect(@mail).to have_xpath "//table//strong[text()='User Information']"
    expect(@mail).to have_xpath "//th[text()='User Modification']/following-sibling::th[text()='Contact Information']/following-sibling::th[text()='Role']/following-sibling::th[text()='SPARC Proxy Rights']"
    expect(@mail).not_to have_xpath "//following-sibling::th[text()='Epic Access']"

    if delete
      [modified_identity.full_name, modified_identity.email, modified_identity.project_roles.first.role.upcase, modified_identity.project_roles.first.display_rights].each do |text|
        expect(@mail).to have_selector('td del', text: text)
      end

      expect(@mail).to_not have_selector('td del', text: modified_identity.project_roles.first.epic_access ? 'Yes' : 'No')
    else
      expect(@mail).to_not have_selector('td del')
    end
  end
end

RSpec.configure do |config|
  config.include EmailHelpers
  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers
end
