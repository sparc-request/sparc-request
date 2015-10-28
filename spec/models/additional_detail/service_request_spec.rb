require 'rails_helper'

RSpec.describe 'ServiceRequest' do

  describe "get_or_create_line_item_additional_details" do
    before(:each) do
      @service_request = ServiceRequest.new
      @service_request.save(:validate => false)

      @sub_service_request = SubServiceRequest.new
      SubServiceRequest.skip_callback(:save, :after, :update_org_tree)
      @sub_service_request.service_request_id = @service_request.id
      @sub_service_request.save(:validate => false)
      SubServiceRequest.set_callback(:save, :after, :update_org_tree)
      

      @service = Service.new
      @service.save(:validate => false)

      @line_item = LineItem.new
      @line_item.service_id = @service.id
      @line_item.sub_service_request_id = @sub_service_request.id
      @line_item.save(:validate => false)
    end

    it "line_item_additional_details should return an empty array is no additional details present" do
      expect(@service_request.get_or_create_line_item_additional_details).to eq([])
    end

    describe "when additional details present" do
      before(:each) do
        @ad = AdditionalDetail.new
        @ad.enabled = true
        @ad.effective_date = Date.yesterday
        @ad.service_id = @service.id
        @ad.save(:validate => false)
      end

      it "get_or_create_line_item_additional_details should create a line_item_additional_detail" do
        expect{
          results = @service_request.get_or_create_line_item_additional_details
        }.to change{LineItemAdditionalDetail.count}.by(1)
        liad = LineItemAdditionalDetail.where(:line_item_id => @line_item.id)
        expect(@service_request.get_or_create_line_item_additional_details).to eq(liad)
      end

      describe "when multiple sub_service_requests present" do

        before(:each) do
          @sub_service_request2 = SubServiceRequest.new
          SubServiceRequest.skip_callback(:save, :after, :update_org_tree)
          @sub_service_request2.service_request_id = @service_request.id
          @sub_service_request2.save(:validate => false)
          SubServiceRequest.set_callback(:save, :after, :update_org_tree)

          @service2 = Service.new
          @service2.save(:validate => false)

          @line_item2 = LineItem.new
          @line_item2.service_id = @service2.id
          @line_item2.sub_service_request_id = @sub_service_request2.id
          @line_item2.save(:validate => false)

          @ad2 = AdditionalDetail.new
          @ad2.enabled = true
          @ad2.effective_date = Date.yesterday
          @ad2.service_id = @service2.id
          @ad2.save(:validate => false)
        end
        
        it "get_or_create_line_item_additional_details should return multiple line_item_additional_details" do
          expect{
            results = @service_request.get_or_create_line_item_additional_details
          }.to change{LineItemAdditionalDetail.count}.by(2)
          liad = LineItemAdditionalDetail.where(:line_item_id => @line_item.id)
          liad.concat(LineItemAdditionalDetail.where(:line_item_id => @line_item2.id))
          expect(@service_request.get_or_create_line_item_additional_details).to eq(liad)
        end

        describe "when a sub_service_request has multiple service requests" do
          before(:each) do
            @service3 = Service.new
            @service3.save(:validate => false)

            @line_item3 = LineItem.new
            @line_item3.service_id = @service3.id
            @line_item3.sub_service_request_id = @sub_service_request2.id
            @line_item3.save(:validate => false)

            @ad3 = AdditionalDetail.new
            @ad3.enabled = true
            @ad3.effective_date = Date.yesterday
            @ad3.service_id = @service3.id
            @ad3.save(:validate => false)
          end

          it "should return multiple additional details from the same sub_service_request" do
            expect{
              results = @service_request.get_or_create_line_item_additional_details
            }.to change{LineItemAdditionalDetail.count}.by(3)
            liad = LineItemAdditionalDetail.where(:line_item_id => @line_item.id)
            liad.concat(LineItemAdditionalDetail.where(:line_item_id => @line_item2.id))
            liad.concat(LineItemAdditionalDetail.where(:line_item_id => @line_item3.id))
            expect(@service_request.get_or_create_line_item_additional_details).to eq(liad)
          end
        end
      end
    end
  end

  describe "protocol short_title and pi_name" do
    before :each do
      @protocol = Protocol.new
      @protocol.short_title = "Super Short Title"

      @service_request = ServiceRequest.new
      @service_request.protocol = @protocol
    end
    
    it "protocol_short_title should return short title of protocol" do
      expect(@service_request.protocol_short_title).to eq(@protocol.short_title)
    end
    
    it "pi_name should return nil if no project_roles are set" do
      expect(@service_request.pi_name).to eq(nil)
    end
    
    it "pi_name should return the name of the primary investigator" do
      @primary_pi = Identity.new
      @primary_pi.first_name = "Primary"
      @primary_pi.last_name = "Person"
      @primary_pi.email = "test@test.uiowa.edu"
      
      @project_role_pi = ProjectRole.new
      @project_role_pi.identity = @primary_pi
      @project_role_pi.role = 'primary-pi'
      @protocol.project_roles << @project_role_pi
      expect(@service_request.pi_name).to eq("Primary Person (test@test.uiowa.edu)")
    end
  end
  
  describe "service_requester_name" do
    before :each do
      @service_requester =  Identity.new
  
      @service_request = ServiceRequest.new
      @service_request.service_requester = @service_requester
    end
  
    describe "with first and last name" do
      before :each do
        @service_requester.first_name = "Test"
        @service_requester.last_name = "Person"
        @service_requester.email = "test@test.uiowa.edu"
      end
  
      it 'should return first and last name of service_requester' do
        expect(@service_request.service_requester_name).to eq("Test Person (test@test.uiowa.edu)")
      end
    end
  
    describe "with only first name" do
      before :each do
        @service_requester.first_name = "Test"
      end
  
      it 'should return first name of service_requester' do
        expect(@service_request.service_requester_name).to eq("Test  ()")
      end
    end
  
    describe "with only last name" do
      before :each do
        @service_requester.last_name = "Person"
      end
  
      it 'should return last name of service_requester' do
        expect(@service_request.service_requester_name).to eq("Person ()")
      end
    end
  
    describe "with no first or last name or email" do
      it 'should return nil' do
        expect(@service_request.service_requester_name).to eq("()")
      end
    end
  end  
end