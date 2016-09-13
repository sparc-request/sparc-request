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

RSpec.describe ServiceRequestsController do
  stub_controller

  let_there_be_lane
  let_there_be_j
  build_service_request

  describe 'POST ask_a_question' do

    context 'params[:quick_question][:email] and params[:quick_question][:body] absent' do

      it 'should call ask_a_question and then deliver from NO_REPLY_FROM with body "No question asked"' do
        deliverer = double()
        expect(deliverer).to receive(:deliver)
        allow(Notifier).to receive(:ask_a_question) do |quick_question|
          expect(quick_question.to).to eq DEFAULT_MAIL_TO
          expect(quick_question.from).to eq NO_REPLY_FROM
          expect(quick_question.body).to eq 'No question asked'
          deliverer
        end
        xhr :get, :ask_a_question, { quick_question: { email: ''}, quick_question: { body: ''}, id: service_request.id, format: :js }
      end
    end

    context 'params[:quick_question][:email] present' do

      it 'should use question email' do
        deliverer = double()
        expect(deliverer).to receive(:deliver)
        allow(Notifier).to receive(:ask_a_question) do |quick_question|
          expect(quick_question.from).to eq 'from-here@musc.edu'
          deliverer
        end
        xhr :get, :ask_a_question, { id: service_request.id, quick_question: { email: 'from-here@musc.edu' , body: '' }, format: :js }
      end
    end

    context 'params[:quick_question][:body] present' do

      it 'should use question body' do
        deliverer = double()
        expect(deliverer).to receive(:deliver)
        allow(Notifier).to receive(:ask_a_question) do |quick_question|
          expect(quick_question.body).to eq 'is this thing on?'
          deliverer
        end
        xhr :get, :ask_a_question, { id: service_request.id, quick_question: { email: '' }, quick_question: { body: 'is this thing on?' }, format: :js }
      end
    end
  end
end
