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

require 'rails_helper'

RSpec.describe CatalogManager::ServicesHelper do

  let(:user)          { double('User') }
  let(:form_name)     { 'form' }
  let(:institution)   { double('Institution') }
  let(:provider)      { double('Provider') }
  let(:program)       { double('Program') }
  let(:core)          { double('Provider') }

  before { allow(user).to receive(:can_edit_entity?) { true } }

  describe '#display_service_user_rights' do


    it 'should return render form_name if a user has access at the institution level' do
      expect(helper).to receive(:render).and_return("render #{form_name}")
      expect(display_service_user_rights(user, form_name, institution)).to eq "render #{form_name}"
    end

    it 'should return render form_name if a user has access at the provider level' do
      expect(helper).to receive(:render).and_return("render #{form_name}")
      expect(display_service_user_rights(user, form_name, provider)).to eq "render #{form_name}"
    end

    it 'should return render form_name if a user has access at the program level' do
      expect(helper).to receive(:render).and_return("render #{form_name}")
      expect(display_service_user_rights(user, form_name, program)).to eq "render #{form_name}"
    end

    it 'should return render form_name if a user has access at the core level' do
      expect(helper).to receive(:render).and_return("render #{form_name}")
      expect(display_service_user_rights(user, form_name, core)).to eq "render #{form_name}"
    end

    it 'should return a sorry message if a user DOES NOT have access' do
      allow(user).to receive(:can_edit_entity?).and_return(false)

      expect(self).to receive(:content_tag).with(:h1, 'Sorry, you are not allowed to access this page.').and_return('Sorry, you are not allowed to access this page.')
      expect(self).to receive(:content_tag).with(:h3, 'Please contact your system administrator.', style: 'color:#999').and_return('Please contact your system administrator.')
      expect(display_service_user_rights(user, form_name, institution)).to eq "Sorry, you are not allowed to access this page.Please contact your system administrator."
    end
  end
end
