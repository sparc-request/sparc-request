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

require 'rails_helper'

RSpec.describe ProtocolsHelper, type: :helper do
  let!(:protocol) { create(:study_federally_funded) }

  describe '#protocol_details_button' do
    context 'in dashboard' do
      before(:each) { allow(helper).to receive(:in_dashboard?).and_return(true) }

      it 'should render the button' do
        expect(helper).to receive(:link_to).with(dashboard_protocol_path(protocol), any_args)
        helper.protocol_details_button(protocol)
      end
    end

    context 'not in dashboard' do
      before(:each) { allow(helper).to receive(:in_dashboard?).and_return(false) }

      it 'should render the button' do
        expect(helper).to receive(:link_to).with(protocol_path(protocol, srid: 1), any_args)
        helper.protocol_details_button(protocol, srid: 1)
      end
    end
  end



  describe '#edit_protocol_button' do
    context 'in dashboard' do
      before(:each) { allow(helper).to receive(:in_dashboard?).and_return(true) }

      context 'with permissions' do
        it 'should render the button' do
          expect(helper).to receive(:link_to).with(edit_dashboard_protocol_path(protocol), any_args)
          helper.edit_protocol_button(protocol, permission: true)
        end
      end

      context 'without permissions' do
        it 'should not render the button' do
          expect(helper.edit_protocol_button(protocol, permission: false)).to be_nil
        end
      end
    end

    context 'not in dashboard' do
      before(:each) { allow(helper).to receive(:in_dashboard?).and_return(false) }

      it 'should render the button' do
        expect(helper).to receive(:link_to).with(edit_protocol_path(protocol, srid: 1), any_args)
        helper.edit_protocol_button(protocol, srid: 1)
      end
    end
  end



  describe '#archive_protocol_button' do
    before(:each) { allow(helper).to receive(:in_dashboard?).and_return(true) }

    context 'with permissions' do
      it 'should render the button' do
        expect(helper).to receive(:link_to).with(archive_dashboard_protocol_path(protocol), any_args)
        helper.archive_protocol_button(protocol, permission: true)
      end
    end

    context 'without permissions' do
      it 'should not render the button' do
        expect(helper.archive_protocol_button(protocol, permission: false)).to be_nil
      end
    end
  end
end
