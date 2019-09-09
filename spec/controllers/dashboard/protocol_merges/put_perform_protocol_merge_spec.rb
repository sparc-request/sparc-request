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

RSpec.describe Dashboard::ProtocolMergesController do

  stub_controller

  context 'user is catalog overlord' do

    context 'master protocol id and merged protocol id are valid' do

      let!(:logged_in_user) { create(:identity, catalog_overlord: true) }
      let!(:protocol_stub_master) { create(:protocol_without_validations) }
      before(:each) do
        log_in_dashboard_identity(obj: logged_in_user)
        allow(controller).to receive(:current_user).and_return(logged_in_user)
        
        protocol_stub_to_be_merged  = create(:protocol_without_validations)

        create(:research_types_info,
               protocol: protocol_stub_master,
               human_subjects: true,
               vertebrate_animals: false,
               investigational_products: false,
               ip_patents: false
              )

        create(:research_types_info,
               protocol: protocol_stub_to_be_merged,
               human_subjects: true,
               vertebrate_animals: false,
               investigational_products: false,
               ip_patents: false
              )

        put :perform_protocol_merge, params: {
            protocol_merge: {master_protocol_id: protocol_stub_master.id, merged_protocol_id: protocol_stub_to_be_merged.id, confirmed: 'false', format: :js }
          }, xhr: true

      end

      it "should call has_research?  and return true" do
        allow(controller).to receive(:has_research?).with(protocol_stub_master, "human_subjects").and_return(true)
      end

      it "should not see any errors" do
        expect(assigns(:errors)).to be_empty
      end

      it { is_expected.to respond_with :ok }
      it { is_expected.to render_template :perform_protocol_merge}
    end
  end

  context 'user is catalog overlord' do

    context 'master protocol id and merged protocol id are empty' do

      let!(:logged_in_user) { create(:identity, catalog_overlord: true) }

      before(:each) do

        log_in_dashboard_identity(obj: logged_in_user)
        allow(controller).to receive(:current_user).and_return(logged_in_user)

        put :perform_protocol_merge, params: {
            protocol_merge: {master_protocol_id: '', merged_protocol_id: '', confirmed: 'false', format: :js }
          }, xhr: true

      end

      it { expect(assigns(:errors)).to be }
    end
  end
end