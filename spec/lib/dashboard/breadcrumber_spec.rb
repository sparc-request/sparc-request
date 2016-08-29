require 'rails_helper'

RSpec.describe Dashboard::Breadcrumber do
  include RSpecHtmlMatchers

  before(:each) { @breadcrumber = Dashboard::Breadcrumber.new }

  describe '#clear' do
    context 'with no arguments' do
      it 'should remove every breadcrumb' do
        @breadcrumber.add_crumb(:protocol_id, 1)

        @breadcrumber.clear

        breadcrumbs = @breadcrumber.breadcrumbs
        expect(breadcrumbs).to have_tag('a', count: 1)
        expect(breadcrumbs).to have_tag('a', with: { href: "/dashboard/protocols" }, text: "Dashboard")
      end
    end

    context 'with symbol' do
      it 'should remove that breadcrumb' do
        @breadcrumber.add_crumb(:protocol_id, 1)

        @breadcrumber.clear(:protocol_id)

        breadcrumbs = @breadcrumber.breadcrumbs
        expect(breadcrumbs).to have_tag('a', count: 1)
        expect(breadcrumbs).to have_tag('a', with: { href: "/dashboard/protocols" }, text: "Dashboard")
      end
    end
  end

  describe '#add_crumb' do
    it 'should add a breadcrumb' do
      allow(Protocol).to receive(:find).with(1).and_return(instance_double(Protocol, short_title: "My Protocol"))

      @breadcrumber.add_crumb(:protocol_id, 1)

      breadcrumbs = @breadcrumber.breadcrumbs
      expect(breadcrumbs).to have_tag('li', text: "(1) My Protocol")
    end
  end

  describe '#add_crumbs' do
    it 'should add multiple breadcrumbs' do
      allow(Protocol).to receive(:find).with(1).and_return(instance_double(Protocol, short_title: "My Protocol"))
      allow(SubServiceRequest).to receive(:find).with(2).and_return(
          instance_double(SubServiceRequest, organization: instance_double(Organization, label: "MegaCorp")))

      @breadcrumber.add_crumbs(protocol_id: 1, sub_service_request_id: 2)

      breadcrumbs = @breadcrumber.breadcrumbs
      expect(breadcrumbs).to have_tag('a', with: { href: "/dashboard/protocols/1" }, text: "(1) My Protocol" )
      expect(breadcrumbs).to have_tag('li', text: "MegaCorp")
    end
  end

  describe '#breadcrumbs' do
    context 'with no crumbs' do
      it 'should return link to Dashboard' do
        breadcrumbs = @breadcrumber.breadcrumbs
        expect(breadcrumbs).to have_tag('a', count: 1)
        expect(breadcrumbs).to have_tag('a', with: { href: "/dashboard/protocols" }, text: "Dashboard")
      end
    end

    context 'with crumbs' do
      it 'should render the links with the correct text in the correct order' do
        allow(Protocol).to receive(:find).with(1).and_return(instance_double(Protocol, short_title: "My Protocol"))
        allow(SubServiceRequest).to receive(:find).with(2).and_return(
            instance_double(SubServiceRequest, organization: instance_double(Organization, label: "MegaCorp")))
        
        @breadcrumber.add_crumbs(protocol_id: 1, sub_service_request_id: 2, edit_protocol: 1)

        breadcrumbs = @breadcrumber.breadcrumbs

        expect(breadcrumbs).to have_tag('a', count: 3) # expect correct number of links, so the following is exhaustive
        expect(breadcrumbs).to have_tag('a', with: { href: "/dashboard/protocols" }, text: "Dashboard")
        expect(breadcrumbs).to have_tag('a', with: { href: "/dashboard/protocols/1" }, text: "(1) My Protocol")
        expect(breadcrumbs).to have_tag('li', text: "Edit")
        expect(breadcrumbs).to match(/Dashboard.*My Protocol.*Edit/) # expect correct order
      end
    end
  end
end
