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

RSpec.describe "protocols/_view_details.html.haml", type: :view do

  context 'viewing project' do
    let!(:protocol) { create(:project_without_validations, primary_pi: create(:identity)) }

    it 'should render protocol and financial information' do
      render 'protocols/view_details', protocol: protocol

      expect(response).to render_template('protocols/view_details/_protocol_information')
      expect(response).to render_template('protocols/view_details/_financial_information')
      expect(response).to_not render_template('protocols/view_details/_research_involving')
      expect(response).to_not render_template('protocols/view_details/_other_details')
    end
  end

  context 'viewing study' do
    let!(:protocol) { create(:study_without_validations, primary_pi: create(:identity)) }

    it 'should render protocol, financial, research involving, and other details' do
      render 'protocols/view_details', protocol: protocol

      expect(response).to render_template('protocols/view_details/_protocol_information')
      expect(response).to render_template('protocols/view_details/_financial_information')
      expect(response).to render_template('protocols/view_details/_research_involving')
      expect(response).to render_template('protocols/view_details/_other_details')
    end
  end
end
