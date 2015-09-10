# coding: utf-8
# Copyright © 2011 MUSC Foundation for Research Development
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

require 'ostruct'

RSpec.describe Portal::ApplicationHelper do
  include Portal::ApplicationHelper

  # This method is broken

  # context :string_to_date do
  #   it "should turn a string into a date" do
  #     string_to_date("10/1/2013").should eq('10/01/2013')
  #   end

  #   it "should rescue" do
  #     string_to_date("AHOY THERE MATEY!").should eq('AHOY THERE MATEY!')
  #   end
  # end

  context '#cents_to_dollars' do
    it "should convert 200 cents to 2.00 dollars" do
      expect(cents_to_dollars(200)).to eq(2.0)
    end

    it "should rescue" do
      expect(cents_to_dollars("fdjkasjflkdasf")).to be_nil
    end
  end

  context '#boolean_to_image' do
    it 'should return accept image if boolean is true' do
      boolean = true
      allow(self).to receive(:image_tag).with('accept.png').and_return("<img src='accept.png' />")
      expect(boolean_to_image(boolean)).to include 'accept.png'
    end

    it 'should return cancel image if boolean is false' do
      boolean = false
      allow(self).to receive(:image_tag).with('cancel.png').and_return("<img src='cancel.png' />")
      expect(boolean_to_image(boolean)).to include 'cancel.png'
    end
  end

  # context :document_download_link do
  #   before { class Document; attr_accessor :ticket; end }

  #   it 'should return a link with an alf ticket number appended' do
  #     link = '/link'
  #     Document.should_receive(:ticket).and_return('1a2b3c')
  #     document_download_link(link).should eq '/link?alf_ticket=1a2b3c'
  #   end
  # end

  context '#cancel_or_reset_changes' do
    it 'should display a cancel link to the root path' do
      controller = double('ProjectsController', controller_name: 'projects')
      root_path = '/'
      allow(self).to receive(:link_to).with('Cancel', root_path).and_return("<a href='/'>Cancel</a>")
      expect(cancel_or_reset_changes(controller)).to include 'Cancel'
    end

    it 'should display a reset changes link to the admin path' do
      controller = double('ProjectsController', controller_name: 'admin')
      allow(self).to receive(:link_to).with('Reset Changes', service_request_related_service_request_path, anchor: '#project').and_return("<a href='#{service_request_related_service_request_path}'>Reset Changes</a>")
      expect(cancel_or_reset_changes(controller)).to include 'Reset Changes'
    end
  end

  context '#hidden_ssr_id' do
    it "should display nothing when not in the related service requests controller" do
      controller = double('ProjectsController', controller_name: 'projects')
      expect(hidden_ssr_id(controller)).to eq('')
    end

    it "should display a hidden ssr field when in the related service requests controller" do
      controller = double('RelatedServiceRequestsController', controller_name: 'related_service_requests')
      @sub_service_request = double('RelatedServiceRequest', sub_service_request_id: 10)
      allow(self).to receive(:hidden_field_tag).and_return("<input></input>")
      allow(self).to receive(:params).and_return({id: 1})
      expect(hidden_ssr_id(controller)).to eq('<input></input>')
    end
  end

  context '#hidden_friendly_id' do
    it "should display nothing when not in the related service requests controller" do
      controller = double('ProjectsController', controller_name: 'projects')
      expect(hidden_friendly_id(controller)).to eq('')
    end

    it "should display a hidden friendly id field when in the related service requests controller" do
      controller = double('RelatedServiceRequestsController', controller_name: 'related_service_requests')
      @service_request = double('ServiceRequest', friendly_id: 10)
      allow(self).to receive(:hidden_field_tag).and_return("<input></input>")
      expect(hidden_friendly_id(controller)).to eq('<input></input>')
    end
  end

  context '#pretty_ssr_id' do
    it "should return a display string for the ids" do
      project = double('Project', id: 5001)
      ssr = double('SubServiceRequest', ssr_id: '0002')
      expect(pretty_ssr_id(project, ssr)).to eq("5001-0002")
    end
  end

  context '#pretty_submitted_at' do
    it "should return a pretty submitted at" do
      sr = double('ServiceRequest', submitted_at: '10/10/2012')
      expect(pretty_submitted_at(sr)).to eq("10/10/12")
    end

    it "should return a pretty submitted at" do
      expect(pretty_submitted_at('')).to eq("Not Yet Submitted")
    end
  end

  context '#display_user_role' do

    let(:user)            { double('User', role: "Hola")}
    let(:other_role_user) { double('User', role: "other", role_other: "DUDESUP") }

    it "Should display user roles" do
      expect(display_user_role(user)).to eq('Hola')
    end

    it "Should display a humanized role_other when a user has 'other' for a role" do
      expect(display_user_role(other_role_user)).to eq('Dudesup')
    end

    it "Should display a humanized role_other when a user has 'other' for a role" do
      expect(display_user_role(other_role_user)).to eq('Dudesup')
    end
  end

  # path helpers for Portal::ApplicationHelper
  def root_path
    '/'
  end

  def service_request_related_service_request_path
    "/admin/service_requests/001/related_service_requests/0001"
  end
end
