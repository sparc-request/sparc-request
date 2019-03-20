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

RSpec.describe Surveyor::ResponseFiltersController, type: :controller do
  stub_controller
  let!(:before_filters) { find_before_filters }
  let!(:logged_in_user) { create(:identity) }

  before :each do
    @filter = create(:response_filter, identity: logged_in_user)

    session[:identity_id] = logged_in_user.id
  end

  describe '#create' do
    it 'should call before_filter #authenticate_identity!' do
      expect(before_filters.include?(:authenticate_identity!)).to eq(true)
    end

    context 'ResponseFilter is valid' do
      before :each do
        post :create, params: {
          response_filter: @filter.attributes
        }, xhr: true
      end

      it 'should assign @response_filter' do
        expect(assigns(:response_filter)).to be_a(ResponseFilter)
      end

      it 'should save @response_filter' do
        expect(assigns(:response_filter).new_record?).to eq(false)
        expect(assigns(:response_filter).attributes.except('id', 'created_at', 'updated_at', 'start_date', 'end_date')).to eq(@filter.attributes.except('id', 'created_at', 'updated_at', 'start_date', 'end_date'))
      end

      it { is_expected.to respond_with(:ok) }
      it { is_expected.to render_template(:create) }
    end

    context 'ResponseFilter is invalid' do
      before :each do
        post :create, params: {
          response_filter: @filter.attributes.except('name').merge(name: '')
        }, xhr: true
      end

      it 'should assign @response_filter' do
        expect(assigns(:response_filter)).to be_a_new(ResponseFilter)
      end

      it 'should assign @errors' do
        expect(assigns(:errors)).to be
      end

      it { is_expected.to respond_with(:ok) }
      it { is_expected.to render_template(:create) }
    end
  end
end
