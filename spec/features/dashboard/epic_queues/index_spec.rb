# Copyright © 2011-2019 MUSC Foundation for Research Development~
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

RSpec.describe 'Notifications index', js: true do
  let!(:user) do
    create(:identity,
           last_name: "Doe",
           first_name: "John",
           ldap_uid: "jug2",
           email: "johnd@musc.edu",
           password: "p4ssword",
           password_confirmation: "p4ssword",
           approved: true)
  end

  let!(:protocol) { create(:unarchived_study_without_validations, primary_pi: user, last_epic_push_status: 'failed') }
  let!(:epic_queue) { create(:epic_queue, protocol_id: protocol.id, identity: user) }
  let!(:epic_queue_record) do
    create(:epic_queue_record,
           protocol: protocol,
           identity: user,
           status: 'complete',
          )
  end

  fake_login_for_each_test("jug2")

  def visit_epic_queues_index_page
    page = Dashboard::EpicQueues::IndexPage.new
    page.load
    page
  end

  stub_config("use_epic", true)
  stub_config("epic_queue_access", ['jug2'])
  
  describe "Epic Queue Table" do
    context 'panel title' do
      it 'should display a title of current and past' do
        visit_epic_queues_index_page
        expect(page).to have_css('.nav-link.active', text: 'Current')
        expect(page).to have_css('.nav-link', text: 'Past')
      end
    end
    context "Queued protocol header" do
      it "should display formatted protocol name" do
        create(:protocol, :without_validations, identity: user)
        create(:project_role_with_identity_and_protocol, identity: user, protocol: protocol)
        page = visit_epic_queues_index_page
        wait_for_javascript_to_finish
        expect(page).to have_epic_queues(text: "#{protocol.type.capitalize}: #{protocol.id} - #{protocol.short_title}")
      end
    end

    context "PI(s) header" do
      it "should display PI name" do
        create(:protocol, :without_validations, identity: user)
        create(:project_role_with_identity_and_protocol, identity: user, protocol: protocol)
        page = visit_epic_queues_index_page
        wait_for_javascript_to_finish

        protocol.principal_investigators.map(&:full_name).each do |pi|
          @pi = "#{pi}"
        end

        expect(page).to have_epic_queues(text: @pi)
      end
    end

    context "Last Queue Date header" do
      it "should display Last Queue Date" do
        create(:protocol, :without_validations, identity: user)
        protocol.update_attribute(:last_epic_push_time, Date.current)
        create(:project_role_with_identity_and_protocol, identity: user, protocol: protocol)
        page = visit_epic_queues_index_page
        wait_for_javascript_to_finish
        wait_for_javascript_to_finish
        date = protocol.last_epic_push_time.strftime("%m/%d/%Y %I:%M:%S %p")

        expect(page).to have_epic_queues(text: "#{date}")
      end
    end

    context "Last Queue Status header" do
      it "should display Last Queue Status" do
        create(:protocol, :without_validations, identity: user)
        protocol.update_attribute(:last_epic_push_status, 'failed')
        create(:project_role_with_identity_and_protocol, identity: user, protocol: protocol)
        page = visit_epic_queues_index_page
        wait_for_javascript_to_finish

        status = protocol.last_epic_push_status.capitalize

        expect(page).to have_epic_queues(text: "#{status}")
      end
    end
  end

  describe 'epic_queue_record_table' do
    it 'should display epic queue record protocol' do
      visit_epic_queues_index_page
      wait_for_javascript_to_finish

      click_link 'Past'

      expect(page).to have_css('td',
        text: "#{protocol.type.capitalize}: #{protocol.id} - #{protocol.short_title}"
      )
    end

    it "should display Last Queue Status" do
      page = visit_epic_queues_index_page
      wait_for_javascript_to_finish

      click_link 'Past'

      expect(page).to have_css('td', text: "#{epic_queue_record.status.capitalize}")
    end
  end

  it "should display PI name" do
    page = visit_epic_queues_index_page

    click_link 'Past'
    protocol.principal_investigators.map(&:full_name).each do |pi|
      @pi = "#{pi}"
    end

    expect(page).to have_css('td', text: @pi)
  end

  it "should display Last Queue Date" do
    page = visit_epic_queues_index_page
    wait_for_javascript_to_finish

    click_link 'Past'
    date = epic_queue.created_at.strftime("%m/%d/%Y %I:%M:%S %p")

    expect(page).to have_css('td', text: "#{date}")
  end

  it 'should display identity associated to eqr' do
    page = visit_epic_queues_index_page

    click_link 'Past'

    expect(page).to have_css('td', text: "#{user.full_name}")
  end
end

