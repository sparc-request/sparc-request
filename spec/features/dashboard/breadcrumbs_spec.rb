require 'rails_helper'

RSpec.describe 'breadcrumbs', js: :true do
  let_there_be_lane
  fake_login_for_each_test
  let!(:protocol) { create(:protocol_federally_funded, :without_validations, primary_pi: jug2, type: 'Project', archived: false, short_title: 'abc', short_title: 'Short Title') }
  let!(:ssr) do
    sr = create(:service_request_without_validations, protocol: protocol, service_requester: jug2)
    create(:sub_service_request, ssr_id: '0001', service_request: sr, organization: create(:organization, admin: jug2, type: 'Institution', abbreviation: 'Organists'), status: 'draft')
  end

  let!(:targets) { [:dashboard, :protocol, :ssr, :notifications].freeze }
  let!(:paths) { { dashboard: '/dashboard/protocols',
    protocol: "/dashboard/protocols/#{protocol.id}",
    ssr: "/dashboard/sub_service_requests/#{ssr.id}",
    notifications: '/dashboard/notifications' }.freeze }

  shared_examples_for 'only dashboard' do
    it 'should consist only of Dashboard' do
      crumbs = find_all('#breadcrumbs a')
      expect(crumbs.map(&:text)).to eq ['Dashboard']
      expect(crumbs.map { |c| c['href'] }).to eq [paths[:dashboard]]
    end
  end

  shared_examples_for 'dashboard, protocol short title, and organization name' do
    it 'should consist of dashboard, protocol short title, and organization name' do
      crumbs = find_all('#breadcrumbs a')
      expect(crumbs.map(&:text)).to eq ['Dashboard', 'Short Title', 'Organists']
      expect(crumbs.map { |c| c['href'] }).to eq [paths[:dashboard], paths[:protocol], paths[:ssr]]
    end
  end

  context 'beginning on dashboard' do
    before(:each) { visit paths[:dashboard] }

    it_behaves_like 'only dashboard'

    context 'after clicking a protocol' do
      before(:each) do
        first('#filterrific_results tr.protocols_index_row td').click
        wait_for_javascript_to_finish
      end

      it 'should consist of Dashboard and protocol short title' do
        crumbs = find_all('#breadcrumbs a')
        expect(crumbs.map(&:text)).to eq ['Dashboard', 'Short Title']
        expect(crumbs.map { |c| c['href'] }).to eq [paths[:dashboard], paths[:protocol]]
      end

      context 'after clicking dashboard' do
        before(:each) do
          first('#breadcrumbs a').click
          wait_for_javascript_to_finish
        end

        it 'should take user to dashboard' do
          expect(URI.parse(current_url).path).to eq paths[:dashboard]
        end

        it_behaves_like 'only dashboard'
      end

      context 'navigating to SubServiceRequest' do
        before(:each) do
          all('.edit_service_request').last.click
        end

        it 'should take user to admin edit' do
          expect(URI.parse(current_url).path).to eq paths[:ssr]
        end

        it_behaves_like 'dashboard, protocol short title, and organization name'
      end

      context 'navigating to notifications' do
        before(:each) {  }
      end
    end

    context 'navigating to SubServiceRequest' do
      context 'navigating to dashboard' do
      end

      context 'navigating to protocol' do
      end

      context 'navigating to notifications' do
      end
    end

    context 'navigating to notifications' do
      context 'navigating to dashboard' do
      end

      context 'navigating to protocol' do
      end

      context 'navigating to SubServiceRequest' do
      end
    end
  end

  context 'beginning on protocol' do
    before(:each) { visit paths[:protocol] }

    context 'navigating to dashboard' do
      context 'navigating to protocol' do
      end

      context 'navigating to SubServiceRequest' do
      end

      context 'navigating to notifications' do
      end
    end

    context 'navigating to SubServiceRequest' do
      before(:each) do
        all('.edit_service_request').last.click
      end

      it 'should take user to admin edit' do
        expect(URI.parse(current_url).path).to eq paths[:ssr]
      end

      it_behaves_like 'dashboard, protocol short title, and organization name'

      context 'navigating to dashboard' do
      end

      context 'navigating to protocol' do
      end

      context 'navigating to notifications' do
      end
    end

    context 'navigating to notifications' do
      context 'navigating to dashboard' do
      end
    end
  end

  context 'beginning on SubServiceRequest' do
    context 'navigating to protocol' do
      context 'navigating to dashboard' do
      end

      context 'navigating to SubServiceRequest' do
      end
    end

    context 'navigating to SubServiceRequest' do
      context 'navigating to dashboard' do
      end
    end

    context 'navigating to notifications' do
      context 'navigating to dashboard' do
      end

      context 'navigating to SubServiceRequest' do
      end
    end
  end

  context 'beginning on notifications' do
    context 'navigating to dashboard' do
      context 'navigating to protocol' do
      end

      context 'navigating to SubServiceRequest' do
      end

      context 'navigating to notifications' do
      end
    end

    context 'navigating to protocol' do
      context 'navigating to dashboard' do
      end

      context 'navigating to SubServiceRequest' do
      end

      context 'navigating to notifications' do
      end
    end

    context 'navigating to SubServiceRequest' do
      context 'navigating to protocol' do
      end

      context 'navigating to dashboard' do
      end

      context 'navigating to notifications' do
      end
    end
  end
end
