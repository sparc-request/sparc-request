# Copyright © 2011-2018 MUSC Foundation for Research Development~
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

RSpec.describe 'catalog_manager/shared/_form.html.haml', type: :view do
  context 'organization is an institution' do
    context 'process_ssrs is false' do
      before(:each) do
        @institution = create(:institution)
        user = create(:identity)

        render('catalog_manager/shared/form.html.haml',
                organization: @institution,
                user: user)
      end

      it 'should display the General Information section' do
        expect(response).to have_selector('#general-info')
      end

      it 'should display the User Rights section' do
        expect(response).to have_selector('#user-rights')
      end

      it 'should not display the Pricing section' do
        expect(response).to_not have_selector('#pricing')
      end

      it 'should not display the Associated Surveys section' do
        expect(response).to_not have_selector('#associated-surveys')
      end

      it 'should not display Status Options section' do
        expect(response).to_not have_selector('#status-options')
      end
    end

    context 'process_ssrs is true' do
      before(:each) do
        @institution = create(:institution, process_ssrs: true)
        user = create(:identity)

        render('catalog_manager/shared/form.html.haml',
                organization: @institution,
                user: user)
      end

      it 'should display Status Options section if process_ssrs is true' do
        expect(response).to have_selector('#status-options')
      end
    end
  end

  context 'organization is a provider' do
    context 'process_ssrs is false' do
      before(:each) do
        @provider = create(:provider)
        user = create(:identity)

        render('catalog_manager/shared/form.html.haml',
                organization: @provider,
                user: user)
      end

      it 'should display the General Information section' do
        expect(response).to have_selector('#general-info')
      end

      it 'should display the User Rights section' do
        expect(response).to have_selector('#user-rights')
      end

      it 'should display the Pricing section' do
        expect(response).to have_selector('#pricing')
      end

      it 'should display the Associated Surveys section' do
        expect(response).to have_selector('#associated-surveys')
      end

      it 'should not display Status Options section' do
        expect(response).to_not have_selector('#status-options')
      end
    end

    context 'process_ssrs is true' do
      before(:each) do
        @provider = create(:provider, process_ssrs: true)
        user = create(:identity)

        render('catalog_manager/shared/form.html.haml',
                organization: @provider,
                user: user)
      end

      it 'should display Status Options section if process_ssrs is true' do
        expect(response).to have_selector('#status-options')
      end
    end
  end

  context 'organization is a program' do
    context 'process_ssrs is false' do
      before(:each) do
        @program = create(:program, process_ssrs: false)
        user = create(:identity)

        render('catalog_manager/shared/form.html.haml',
                organization: @program,
                user: user)
      end

      it 'should display the General Information section' do
        expect(response).to have_selector('#general-info')
      end

      it 'should display the User Rights section' do
        expect(response).to have_selector('#user-rights')
      end

      it 'should display the Pricing section' do
        expect(response).to have_selector('#pricing')
      end

      it 'should display the Associated Surveys section' do
        expect(response).to have_selector('#associated-surveys')
      end

      it 'should not display Status Options section' do
        expect(response).to_not have_selector('#status-options')
      end
    end

    context 'process_ssrs is true' do
      before(:each) do
        @program = create(:program, process_ssrs: true)
        user = create(:identity)

        render('catalog_manager/shared/form.html.haml',
                organization: @program,
                user: user)
      end

      it 'should display Status Options section if process_ssrs is true' do
        expect(response).to have_selector('#status-options')
      end
    end
  end

  context 'organization is a core' do
    context 'process_ssrs is false' do
      before(:each) do
        @core = create(:core)
        user = create(:identity)

        render('catalog_manager/shared/form.html.haml',
                organization: @core,
                user: user)
      end

      it 'should display the General Information section' do
        expect(response).to have_selector('#general-info')
      end

      it 'should display the User Rights section' do
        expect(response).to have_selector('#user-rights')
      end

      it 'should display the Pricing section' do
        expect(response).to have_selector('#pricing')
      end

      it 'should display the Associated Surveys section' do
        expect(response).to have_selector('#associated-surveys')
      end

      it 'should not display Status Options section' do
        expect(response).to_not have_selector('#status-options')
      end
    end

    context 'process_ssrs is true' do
      before(:each) do
        @core = create(:core, process_ssrs: true)
        user = create(:identity)

        render('catalog_manager/shared/form.html.haml',
                organization: @core,
                user: user)
      end

      it 'should display Status Options section if process_ssrs is true' do
        expect(response).to have_selector('#status-options')
      end
    end
  end
end
