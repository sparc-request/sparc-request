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

RSpec.describe 'catalog_manager/services/_form.html.haml', type: :view do
  def render_view(service)
    render 'catalog_manager/services/form', service: service
  end

  let!(:provider) { build_stubbed(:provider) }
  let!(:program)  { build_stubbed(:program, :process_ssrs, parent: provider) }
  let!(:service)  { build_stubbed(:service, organization: program) }

  before :each do
    @user = build_stubbed(:identity)
    allow(@user).to receive(:can_edit_service?).with(service).and_return(true)
    assign(:user, @user)
    assign(:programs, Program.none)
    assign(:cores, Core.none)
    ActionView::Base.send(:define_method, :current_user) { @user }
  end

  describe 'Service Level Components panel' do
    context 'service is a non-clinical service' do
      before :each do
        allow(service).to receive(:one_time_fee?).and_return(true)
      end
      context 'organization is tagged for fulfillment' do
        before :each do
          allow(program).to receive(:tag_list).and_return("clinical work fulfillment")
          render_view(service)
        end

        it 'should show the panel' do
          expect(response).to have_selector('#service-components:not(.hidden)')
        end
      end

      context 'organization is not tagged for fulfillment' do
        before :each do
          allow(program).to receive(:tag_list).and_return("")
          render_view(service)
        end

        it 'should hide the panel' do
          expect(response).to have_selector('#service-components.hidden')
        end
      end
    end

    context 'service is a clinical service' do
      before :each do
        allow(service).to receive(:one_time_fee?).and_return(false)
        render_view(service)
      end

      it 'should hide the panel' do
        expect(response).to have_selector('#service-components.hidden')
      end
    end
  end
end
