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

RSpec.describe AdditionalDetails::SubmissionsController do

	describe '#new' do

		it 'should instantiate a submission object' do

      service = create( :service )

      xhr :get, :new, service_id: service.id

      expect( assigns( :submission ).class ).to eq( Submission )

      expect( assigns( :submission ).new_record? ).to eq( true )

    end

    it 'should build the submissions questionnaire_responses' do

      service = create( :service )

      xhr :get, :new, service_id: service.id

      expect( assigns( :submission ).questionnaire_responses.nil? ).to eq( false )

    end
  end

  describe '#edit' do

    it 'should return the correct Service and Submission' do

      service = create( :service )
      submission = create( :submission )

      xhr :get, :edit, service_id: service.id, id: submission

      expect( assigns( :submission ) ).to eq( submission )

      expect( assigns ( :service ) ).to eq( service )
    end

    it 'should get the correct Questionnaire' do

      service = create( :service )
      submission = create( :submission )

      xhr :get, :edit, service_id: service.id, id: submission

      expect( assigns( :questionnaire ) ).to eq( service.questionnaires.active.first )
    end
  end

  describe '#create' do

    context 'successful' do

      it 'should create a new Submissions record' do

        service = create( :service )
        protocol = create( :protocol_without_validations )
        line_item = create( :line_item_without_validations )
        identity = create( :identity )
        submission = { identity_id: identity.id,
                       protocol_id: protocol.id,
                       line_item_id: line_item.id }

        expect{ xhr( :post, 
                     :create, 
                     submission: submission, 
                     service_id: service.id ) }.to change{ Submission.count }.by( 1 )
      end
    end
  end

  describe '#update' do

    it 'should update the Submission record' do

      service = create( :service )
      protocol = create( :protocol_without_validations )
      line_item = create( :line_item_without_validations )
      service_request = create( :service_request_without_validations )
      submission = create( :submission )
      response = { "0" => { content: "This is the updated text "} }
      new_submission = { protocol_id: protocol.id,
                         line_item_id: line_item.id,
                         questionnaire_responses_attributes: response }

      xhr :patch, :update, service_id: service.id, submission: new_submission, sr_id: service_request.id, id: submission

      expect( assigns( :submission ).questionnaire_responses.count ).to eq( 1 )

      expect( assigns( :submission ).protocol_id ).to eq( protocol.id )

      expect( assigns( :submission ).line_item_id ).to eq( line_item.id )

    end
  end

  describe '#destroy' do

    it 'should destroy the Submission record' do

      service = create( :service )
      service_request = create( :service_request_without_validations )
      submission = create( :submission )

      expect{ xhr :delete, :destroy, service_id: service.id, id: submission }.to change{ Submission.count }.by( -1 )
    end

    it 'should remove the dependents when destroyed' do
      
      service = create( :service )
      service_request = create( :service_request_without_validations )
      submission = create( :submission, questionnaire_responses_attributes: { "0" => { content: "This is the updated text "} } )

      expect{ xhr :delete, :destroy, service_id: service.id, id: submission }.to change{ QuestionnaireResponse.count }.by( -1 )
    end

    it 'should remove the record when its attached to a protocol' do

      service = create( :service )
      service_request = create( :service_request_without_validations )
      submission = create( :submission )
      protocol = create(:protocol_without_validations, submissions: [submission])

      expect{ xhr :delete, :destroy, service_id: service.id, id: submission, protocol_id: protocol.id }.to change{ protocol.submissions.count }.by( -1 )
    end
  end
end