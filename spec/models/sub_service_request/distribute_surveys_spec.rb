require 'rails_helper'

RSpec.describe SubServiceRequest, type: :model do

  describe "#distribute_surveys" do
    before { SubServiceRequest.skip_callback(:save, :after, :update_org_tree) }
    after { SubServiceRequest.set_callback(:save, :after, :update_org_tree) }
      
    context 'we have available surveys' do
      before :each do
        @pi                    = create(:identity)
        @service_requester = create(:identity)
        @protocol             = create(:protocol_without_validations)
        create(:project_role, identity_id:  @pi.id, protocol_id:  @protocol.id, role: 'primary-pi')
        @service_request      = create(:service_request_without_validations, protocol: @protocol)
        @organization         = create(:organization)
        @survey               = create(:survey, access_code: 'sctr-customer-satisfaction-survey')
        @sub_service_request  = create(:sub_service_request_without_validations, 
                                        service_request: @service_request, 
                                        organization: @organization, 
                                        service_requester_id:  @service_requester.id)
        @service              = create(:service_without_validations, organization_id:  @organization.id)
        @line_item            = create(:line_item_without_validations, 
                                        service_request_id: @service_request.id,                          
                                        service_id:  @service.id,
                                        sub_service_request_id: @sub_service_request.id)
        @organization.associated_surveys.create survey_id: @survey.id
      end

      context 'should distribute surveys' do
        context 'when primary pi and ssr requester are uniq' do
          it 'to both primary pi and ssr requester' do
            expect { @sub_service_request.distribute_surveys }.to change { ActionMailer::Base.deliveries.count }.by(2)
          end
        end
        context 'when primary pi and ssr requester are the same' do
          it 'to only primary pi' do
            @sub_service_request.update_attribute(:service_requester_id, @pi.id)
            expect { @sub_service_request.distribute_surveys }.to change { ActionMailer::Base.deliveries.count }.by(1)
          end
        end
      end
    end

    context 'we do not have available surveys' do
      before :each do
        @pi                    = create(:identity)
        @service_requester = create(:identity)
        @protocol             = create(:protocol_without_validations)
        create(:project_role, identity_id:  @pi.id, protocol_id:  @protocol.id, role: 'primary-pi')
        @service_request      = create(:service_request_without_validations, protocol: @protocol)
        @organization         = create(:organization)
        @survey               = create(:survey, access_code: 'sctr-customer-satisfaction-survey')
        @sub_service_request  = create(:sub_service_request_without_validations, 
                                        service_request: @service_request, 
                                        organization: @organization, 
                                        service_requester_id:  @service_requester.id)
      end

      it 'should not distribute surveys' do
        expect { @sub_service_request.distribute_surveys }.to change { ActionMailer::Base.deliveries.count }.by(0)
      end
    end
  end
end