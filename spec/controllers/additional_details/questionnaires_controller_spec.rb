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

RSpec.describe AdditionalDetails::QuestionnairesController do
	describe '#create' do
		before :each do
			@service = create( :service )
	    @questionnaire = build( :questionnaire, service: @service, active: false )

	  	xhr :post, :create, service_id: @service, questionnaire: @questionnaire.attributes, format: :js
		 end

	  it 'should assign @questionnaire' do
	  	expect( assigns( :questionnaire ) ).to be_an_instance_of( Questionnaire )
	  end

	  it 'should assign @service' do
	  	expect( assigns( :service ) ).to be_an_instance_of( Service )
		end

    it { is_expected.to respond_with :found }
	end

	describe '#update' do

		before :each do

			@service = create( :service )
			@questionnaire= create( :questionnaire, service: @service, active: false )

      @questionnaire.items.build

			@question = { id: 1,
                  content: 'This is the original text', 
									item_type: "text", 
									item_options_attributes: { "0" => { content: ""} }, 
								  description: "", 
								  required: "0" } 

      @questionnaire.items << Item.create(@question)

      @question[:content] = 'This is the changed text'

      questionnaire_params = @questionnaire.attributes.merge( { items_attributes:  { "0" => @question } } )

			@params = { name: "This should be changed", 
									id: @questionnaire.id,
									service_id: @service.id,
									questionnaire: questionnaire_params }

			xhr :put, :update, @params, format: :js
		end

		it 'should assign the question to the questionnaire' do
			expect(@questionnaire.items[0]).to eq( Item.new( @question) )
		end


	end
end