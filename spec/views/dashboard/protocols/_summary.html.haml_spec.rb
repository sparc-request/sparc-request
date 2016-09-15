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

RSpec.describe 'dashboard/protocols/summary', type: :view do
  def render_summary_for protocol
    render 'dashboard/protocols/summary',
      protocol: protocol,
      protocol_type: protocol.type,
      permission_to_edit: true
  end

  let_there_be_lane

  context 'Protocol is a Study' do
    it 'should be titled "Study Summary"' do
      protocol = build(:protocol_federally_funded,
        :without_validations,
        primary_pi: jug2,
        type: 'Study',
        archived: false,
        short_title: 'My Awesome Short Title')

      render_summary_for protocol

      expect(response).to have_content('Study Summary')
    end

    it 'should display a "Study Notes" button' do
      protocol = build(:protocol_federally_funded,
        :without_validations,
        primary_pi: jug2,
        type: 'Study',
        archived: false,
        title: 'Study_Title',
        short_title: 'Study_Short_Title')

      render_summary_for protocol

      expect(response).to have_selector('button', exact: 'Study Notes')
    end

    context 'Study has potential funding source' do
      it 'should display Study ID, Title, Short Title, and potential funding source' do
        protocol = build(:protocol_federally_funded,
          :without_validations,
          primary_pi: jug2,
          type: 'Study',
          archived: false,
          title: 'My Awesome Full Title',
          short_title: 'My Awesome Short Title',
          id: 9999,
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
        protocol = build(:protocol_federally_funded,
          :without_validations,
          primary_pi: jug2,
          type: 'Study',
          archived: false,
          title: 'My Awesome Full Title',
          short_title: 'My Awesome Short Title',
          id: 9999,
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
  end

  context 'Protocol is a Project' do
    it 'should display a "Project Notes" button' do
      protocol = build(:protocol_federally_funded,
        :without_validations,
        primary_pi: jug2,
        type: 'Project',
        archived: false,
        title: 'Project_Title',
        short_title: 'Project_Short_Title')

      render_summary_for protocol

      expect(response).to have_selector('button', exact: 'Project Notes')
    end

    it 'should be titled "Project Summary"' do
      protocol = build(:protocol_federally_funded,
        :without_validations,
        primary_pi: jug2,
        type: 'Project',
        archived: false,
        short_title: 'My Awesome Short Title')

      render_summary_for protocol

      expect(response).to have_content('Project Summary')
    end

    context 'Project has potential funding source' do
      it 'should display Project ID, Title, Short Title, and potential funding source' do
        protocol = build(:protocol_federally_funded,
          :without_validations,
          primary_pi: jug2,
          type: 'Project',
          archived: false,
          title: 'My Awesome Full Title',
          short_title: 'My Awesome Short Title',
          id: 9999,
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
        protocol = build(:protocol_federally_funded,
          :without_validations,
          primary_pi: jug2,
          type: 'Project',
          archived: false,
          title: 'My Awesome Full Title',
          short_title: 'My Awesome Short Title',
          id: 9999,
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
  end
end
