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

require 'rails_helper'

RSpec.describe 'protocol sorting', js: :true do
  let!(:user) do
    create(:identity,
           last_name: "Doe",
           first_name: "John",
           ldap_uid: "johnd",
           email: "johnd@musc.edu",
           password: "p4ssword",
           password_confirmation: "p4ssword",
           approved: true)
  end

  fake_login_for_each_test("johnd")

  def visit_protocols_index_page
    page = Dashboard::Protocols::IndexPage.new
    page.load
    page
  end

  it 'should sort protocols' do
    protocol1 = create(:study_without_validations, primary_pi: user)
    protocol2 = create(:study_without_validations, primary_pi: user)
    protocol3 = create(:study_without_validations, primary_pi: user)
    page      = visit_protocols_index_page

    page.first('.protocol-sort').click()
    wait_for_javascript_to_finish

    expect(page.search_results.protocols.first).to have_selector('td', text: protocol1.id)
    expect(page.search_results.protocols.second).to have_selector('td', text: protocol2.id)
    expect(page.search_results.protocols.third).to have_selector('td', text: protocol3.id)
  end

  it 'should have a visual cue' do
    protocol1 = create(:study_without_validations, primary_pi: user)
    page      = visit_protocols_index_page
    page.first('.protocol-sort').click()
    wait_for_javascript_to_finish

    expect(first('.protocol-sort')).to have_selector('.asc.sort-active')
  end

  it 'should alternate orders' do
    protocol1 = create(:study_without_validations, primary_pi: user)
    page      = visit_protocols_index_page

    page.first('.protocol-sort').click()
    wait_for_javascript_to_finish
    page.first('.protocol-sort').click()
    wait_for_javascript_to_finish

    expect(first('.protocol-sort')).to have_selector('.desc.sort-active')
  end
end