require 'spec_helper'

describe Portal::ServiceRequestsHelper do
  include Portal::ApplicationHelper
  include Portal::ServiceRequestsHelper

  context :service_selected do
    it 'should return whether or not an option is selected' do
      service_selected('Test', 'Thing').should be_false
    end

    it 'should return whether or not an option is selected' do
      service_selected('Test', 'Test').should be_true
    end
  end

  context :timeframe_selected do
    it 'should return whether or not an option is selected' do
      timeframe_selected('Test', 'Thing').should be_false
    end

    it 'should return whether or not an option is selected' do
      timeframe_selected('Test', 'Test').should be_true
    end
  end

  context :populate_fulfillment_time do
    it 'should convert time from minutes to whatever timeframe is selected' do
      fulfillment = {'timeframe' => 'Days', 'time' => '1440'}
      populate_fulfillment_time(fulfillment).should == 1.0
    end

    it 'should return accept image if boolean is true' do
      fulfillment = {'timeframe' => 'Hours', 'time' => '120'}
      populate_fulfillment_time(fulfillment).should == 2.0
    end

    it 'should return accept image if boolean is true' do
      fulfillment = {'timeframe' => 'Min', 'time' => '200'}
      populate_fulfillment_time(fulfillment).should == '200'
    end
  end

  context :default_display do
    it "should be shown when it's sumitted" do
      default_display('submitted').should eq('')
    end

    it "should be hidden when it's not sumitted" do
      default_display('asdf').should eq("display:none;")
    end
  end

  context :calculate_status_quantity do
    it "should display the status quantity" do
      srq = [
        mock('ServiceRequest', :status => 'Submitted'),
        mock('ServiceRequest', :status => 'Submitted'),
        mock('ServiceRequest', :status => 'Submitted'),
        mock('ServiceRequest', :status => 'Submitted'),
      ]
      calculate_status_quantity(srq, "Submitted").should eq(4)
    end

    it "should display the status quantity" do
      calculate_status_quantity([], '').should eq(0)
    end
  end

  context :display_requester do
    it "should combine first and last names into a string" do
      requester = {'first_name' => "Duke", 'last_name' => "Ellington"}
      display_requester(requester).should eq("Duke Ellington")
    end
  end

  context :display_pi do
    let(:roles) { [{'role' => 'pi', 'first_name' => "Roberto", 'last_name' => "Pearce"}, {'role' => 'BAMF', 'first_name' => "Nick", 'last_name' => "B"}] }

    it "should display the first and last name of the person with the PI role" do
      display_pi(roles).should eq("Roberto Pearce")
    end
  end

  # Method not being used anywhere -rp
  # context :max_visit_count do
  #   pending "Test this method when you get to fulfillment"
  # end

  context :pre_select_billing_type do
    it "should preselect the billing type" do
      pre_select_billing_type("dude", "sup").should be_false
    end

    it "should preselect the billing type" do
      pre_select_billing_type("dude", "dude").should be_true
    end
  end

  context :display_visit_quantity do
    let(:li) { mock('LineItem', :service_id => '1234', :visits => [{"quantity"=>1, "billing"=>"R"}]) }
    let(:service) { mock('Service', :id => '1234') }
    let(:html) { '<td class="visit_quantity" id="quantity_1234_column_1">1</td>' }

    module Business
      module Pricing
      end
    end

    before do
      li.stub!(:service).and_return(service)
      @visits_array = [{:values=>[{:quantity=>1, :service_id=>"1234"}]}]
      stub!(:create_quantity_content_tag).and_return(html).stub!(:html_safe).and_return('')
      should_receive(:determine_package_cost).and_return(1000)
      should_receive(:sub_totals).and_return([1, 2, 3])
    end

    it 'should return html for the visits table' do
      display_visit_quantity(li).should include(html)
    end

    it 'should render remaining 4 columns even if there is only 1 visit' do
      display_visit_quantity(li).length.should eq(html.length * 5)
    end
  end

  context :create_quantity_content_tag do
    it 'should create a visit header td content tag' do
      should_receive(:content_tag).with(:td, 'asdf', {:class => 'visit_quantity', :id => "quantity_1234_column_12345"}).and_return('<td>')
      create_quantity_content_tag('asdf', 1234, 12345).should eq('<td>')
    end
  end

  context :display_cost_per_service do
    let(:quantity) { '2' }
    let(:full_rate) { '50000' }
    
    it 'should return a correct cost given a quantity and a pricing rate' do
      display_cost_per_service(quantity, full_rate).should eq('$1000.00')
    end
  end

  context :display_service_total do
    let(:li) { LineItem.new("service_id"=>"123", "quantity"=>0, "optional"=>true) }
    let(:li2) { LineItem.new("service_id"=>"321", "quantity"=>6, "optional"=>true, "sub_service_request_id"=>"0003") }

    before do
      lis = [li, li2]
      lis.each { |l| l.stub!(:service).and_return(1) }
      should_receive(:sub_totals).and_return([1, 2, 3])
    end

    it 'should return a string of html with the correct amount for per-patient-per-visit' do
      should_receive(:determine_package_cost).and_return(100)
      should_receive(:two_decimal_places).and_return('900.00')
      display_service_total(li).should eq '$900.00'
    end

    it 'should return a string of html with the correct amount given a one time fee' do
      should_receive(:determine_package_cost).and_return(1000)
      should_receive(:two_decimal_places).and_return('9000.00')
      display_service_total(li2).should eq '$9000.00'
    end
  end

  # TODO: Core (Organization) no longer has attributes like this
  # context :services_are_available do
  #   let (:core) { Core.new('attributes' => {'is_available' => true}) }
  #   let (:service) { Service.new(:is_available => true) }
  #   let (:hash) { {:name => 'dude'} }
  #   let (:li) { LineItem.new(:service => Service.new(:name => 'dude') ) }

  #   it "the services should be available" do
  #     services_are_available(service, hash, li, core).should eq true
  #   end

  #   it "the services should not be available if the core has the false flag set" do
  #     core.attributes['is_available'] = false
  #     services_are_available(service, hash, li, core).should eq false
  #   end

  #   it "the services should not be available if the service has the false flag" do
  #     service.is_available = false
  #     services_are_available(service, hash, li, core).should eq false
  #   end
  # end

end
