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

require 'spec_helper'

describe Portal::ProjectsHelper do
  include Portal::ProjectsHelper

  context :check_or_x do
    it 'should return a check mark icon when true' do
      boolean = true
      should_receive(:content_tag).with(:span, '', :class => 'icon check').and_return("<span class='icon check'></span>")
      check_or_x(boolean).should eq "<span class='icon check'></span>"
    end

    it 'should return an X icon when false' do
      boolean = false
      should_receive(:content_tag).with(:span, '', :class => 'icon uncheck').and_return("<span class='icon uncheck'></span>")
      check_or_x(boolean).should eq "<span class='icon uncheck'></span>"
    end
  end

  # TODO: these tests are broken until we can use FactoryGirl
  # context :pretty_program_core do
  #   it 'should return program_abbreviation/core_abbreviation if there is a core abbreviation' do
  #     ssr = mock(
  #         'ServiceRequest',
  #         :program => mock(:name => 'Development', :abbreviation => 'DEV'),
  #         :organization => mock(:name => 'Bob Loblaw', :abbreviation => 'BLL'))
  #     pretty_program_core(ssr).should eq "DEV/BLL"
  #   end

  #   it 'should return program_name/core_name if there is a core name' do
  #     ssr = mock('ServiceRequest', :program_name => 'Development', :program_abbreviation => nil, :core_name => 'Bob Loblaw', :core_abbreviation => nil)
  #     ssr.core_name.stub!(:blank?).and_return(false)
  #     core = mock('Core', :abbreviation => 'foobar', :name => 'Development/Bob Loblaw')
  #     ssr.stub!(:organization).and_return core
  #     pretty_program_core(ssr).should eq 'Development/Bob Loblaw'
  #   end

  #   it 'should only return program_name if there is not a core name' do
  #     ssr = mock('ServiceRequest', :program_name => 'Development', :program_abbreviation => nil, :core_name => nil, :core_abbreviation => nil)
  #     core = mock('Core', :abbreviation => 'foobar', :name => 'Development')
  #     ssr.stub!(:organization).and_return core
  #     pretty_program_core(ssr).should eq 'Development'
  #   end
  # end

  context :display_funding_source do
    FUNDING_SOURCES ||= {}
    POTENTIAL_FUNDING_SOURCES ||= {}

    before do
      @project = Project.new(:funding_status => "")
      @project.stub!(:id).and_return('abc123')
    end

    it 'should return a potential funding source' do
      @project.stub!(:potential_funding_source).and_return('bob_loblaw')
      @project.funding_status = 'pending_funding'
      POTENTIAL_FUNDING_SOURCES.stub!(:map).and_return(['bob_loblaw' => 'Bob Loblaw'])
      display_funding_source(@project).should eq('Potential Funding Source: Bob Loblaw')
    end

    it 'should return a funding source' do
      @project.stub!(:funding_source).and_return('the_government')
      @project.funding_status = 'funded'
      FUNDING_SOURCES.stub!(:map).and_return(['the_government' => 'The Government'])
      display_funding_source(@project).should eq('Funding Source: The Government')
    end

    it 'should return an empty string' do
      display_funding_source(@project).should eq('')
    end
  end

  context :display_funding_status do
    let(:status) { 'pending_funding' }

    it 'should return a display value given a funding status' do
      display_funding_status(status).should eq('Pending Funding')
    end
  end

  context :display_viewer_funding_source do
    before do
      @project = Project.new
    end

    it 'should return a display value given a project with a potential funding source' do
      @project.stub!(:potential_funding_source).and_return('industry')
      display_viewer_funding_source(@project).should eq('Industry-Initiated/Industry-Sponsored')
    end

    it 'should return a display value given a project with a funding source' do
      @project.stub!(:funding_source).and_return('internal')
      display_viewer_funding_source(@project).should eq('Internal Funded Pilot Project')
    end

  end
end
