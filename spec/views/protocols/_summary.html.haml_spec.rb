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

RSpec.describe 'protocols/summary', type: :view do
  def render_summary_for protocol, action_name=nil
    render '/protocols/summary',
      protocol: protocol,
      user: jug2,
      action_name: action_name,
      service_request: build_stubbed(:service_request)
  end

  let_there_be_lane

  context 'Protocol is a Study' do
    it 'should be titled "Study Summary"' do
      protocol = build_stubbed(:study_federally_funded, primary_pi: jug2)

      render_summary_for protocol, 'protocol'

      expect(response).to have_content(I18n.t('protocols.summary.header', protocol_type: protocol.model_name.human))
    end

    describe 'Edit button' do
      context 'on Step 2: Protocol' do
        it 'should show the Edit button' do
          protocol = build_stubbed(:study_without_validations, primary_pi: jug2)

          render_summary_for protocol, 'protocol'

          expect(response).to have_selector('.edit-protocol', text: I18n.t('protocols.edit', protocol_type: protocol.model_name.human))
        end
      end

      context 'in Review' do
        before :each do
          allow(view).to receive(:in_review?).and_return(true)
        end

        it 'should not show the edit button' do
          protocol = build_stubbed(:study_without_validations, primary_pi: jug2)

          render_summary_for protocol, 'review'

          expect(response).to have_no_selector('.edit-protocol', text: I18n.t('protocols.edit', protocol_type: protocol.model_name.human))
        end
      end
    end

    context 'RMID is enabled' do
      stub_config('research_master_enabled', true)

      it 'should display Research Master ID' do
        protocol = build_stubbed(:study, research_master_id: 1234)

        render_summary_for protocol

        expect(response).to have_content('1234')
      end
    end

    context 'RMID is disabled' do
      stub_config('research_master_enabled', false)

      it 'should not display Research Master ID' do
        protocol = build_stubbed(:study, research_master_id: 1234)

        render_summary_for protocol

        expect(response).to_not have_content('1234')
      end
    end

    context 'Study has potential funding source' do
      it 'should display Study ID, Title, Short Title, and potential funding source' do
        protocol = build_stubbed(:study_federally_funded,
          primary_pi: jug2,
          id: 9999,
          title: 'My Awesome Full Title',
          short_title: 'My Awesome Short Title',
          potential_funding_source: 'federal',
          funding_source: 'college',
          funding_status: 'pending_funding')

        render_summary_for protocol

        expect(response).to have_content('9999')
        expect(response).to have_content('My Awesome Full Title')
        expect(response).to have_content('My Awesome Short Title')

        expect(response).to have_content('Potential Funding Source')
        expect(response).to have_content('Federal')
      end
    end

    context 'Study has a funding source' do
      it 'should display Study ID, Title, Short Title, and potential funding source' do
        protocol = build_stubbed(:study_federally_funded,
          primary_pi: jug2,
          id: 9999,
          title: 'My Awesome Full Title',
          short_title: 'My Awesome Short Title',
          potential_funding_source: 'federal',
          funding_source: 'college',
          funding_status: 'funded')

        render_summary_for protocol

        expect(response).to have_content('9999')
        expect(response).to have_content('My Awesome Full Title')
        expect(response).to have_content('My Awesome Short Title')

        expect(response).not_to have_content('Potential Funding Source')
        expect(response).to have_content('Funding Source')
        expect(response).to have_content('College Department')
      end
    end

    context 'In Dashboard' do
      before :each do
        allow(view).to receive(:in_dashboard?).and_return(true)
      end

      it 'should display the archive button' do
        protocol = build_stubbed(:unarchived_study_without_validations, primary_pi: jug2)

        render '/protocols/summary', protocol: protocol, current_user: jug2, action_name: 'show', permission_to_edit: true, admin: true

        expect(response).to have_selector('.archive-protocol', text: I18n.t('protocols.summary.archive'))
      end
    end

    context 'not in Dashboard' do
      it 'should not display the archive button' do
        protocol = build_stubbed(:unarchived_study_without_validations, primary_pi: jug2)

        render '/protocols/summary', protocol: protocol, service_request: build_stubbed(:service_request), current_user: jug2, action_name: 'protocol', permission_to_edit: true, admin: true

        expect(response).to have_no_selector('.archive-protocol', text: I18n.t('protocols.summary.archive'))
      end
    end
  end

  context 'Protocol is a Project' do
    it 'should be titled "Project Summary"' do
      protocol = build_stubbed(:project_federally_funded, primary_pi: jug2)

      render_summary_for protocol

      expect(response).to have_content(I18n.t('protocols.summary.header', protocol_type: protocol.model_name.human))
    end

    describe 'Edit button' do
      context 'on Step 2: Protocol' do
        it 'should show the Edit button' do
          protocol = build_stubbed(:project_without_validations, primary_pi: jug2)

          render_summary_for protocol, 'protocol'

          expect(response).to have_selector('.edit-protocol', text: I18n.t('protocols.edit', protocol_type: protocol.model_name.human))
        end
      end

      context 'in Review' do
        before :each do
          allow(view).to receive(:in_review?).and_return(true)
        end

        it 'should show the edit button' do
          protocol = build_stubbed(:project_without_validations, primary_pi: jug2)

          render_summary_for protocol, 'review'

          expect(response).to have_no_selector('.edit-protocol', text: I18n.t('protocols.edit', protocol_type: protocol.model_name.human))
        end
      end
    end

    context 'Project has potential funding source' do
      it 'should display Project ID, Title, Short Title, and potential funding source' do
        protocol = build_stubbed(:project_federally_funded,
          primary_pi: jug2,
          id: 9999,
          title: 'My Awesome Full Title',
          short_title: 'My Awesome Short Title',
          potential_funding_source: 'federal',
          funding_source: 'college',
          funding_status: 'pending_funding')

        render_summary_for protocol

        expect(response).to have_content('9999')
        expect(response).to have_content('My Awesome Full Title')
        expect(response).to have_content('My Awesome Short Title')

        expect(response).to have_content('Potential Funding Source')
        expect(response).to have_content('Federal')
      end
    end

    context 'Project has a funding source' do
      it 'should display Project ID, Title, Short Title, and potential funding source' do
        protocol = build_stubbed(:project_federally_funded,
          primary_pi: jug2,
          id: 9999,
          title: 'My Awesome Full Title',
          short_title: 'My Awesome Short Title',
          potential_funding_source: 'federal',
          funding_source: 'college',
          funding_status: 'funded')

        render_summary_for protocol

        expect(response).to have_content('9999')
        expect(response).to have_content('My Awesome Full Title')
        expect(response).to have_content('My Awesome Short Title')

        expect(response).not_to have_content('Potential Funding Source')
        expect(response).to have_content('Funding Source')
        expect(response).to have_content('College Department')
      end
    end

    context 'In Dashboard' do
      before :each do
        allow(view).to receive(:in_dashboard?).and_return(true)
      end

      it 'should display the archive button' do
        protocol = build_stubbed(:unarchived_project_without_validations, primary_pi: jug2)

        render '/protocols/summary', protocol: protocol, current_user: jug2, action_name: 'show', permission_to_edit: true, admin: true

        expect(response).to have_selector('.archive-protocol', text: I18n.t('protocols.summary.archive'))
      end
    end

    context 'not in Dashboard' do
      it 'should not display the archive button' do
        protocol = build_stubbed(:unarchived_project_without_validations, primary_pi: jug2)

        render '/protocols/summary', protocol: protocol, service_request: build_stubbed(:service_request), current_user: jug2, action_name: 'show', permission_to_edit: true, admin: true

        expect(response).to have_no_selector('.archive-protocol', text: I18n.t('protocols.summary.archive'))
      end
    end
  end
end
