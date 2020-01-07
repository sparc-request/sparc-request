# Copyright © 2011-2019 MUSC Foundation for Research Development
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

RSpec.describe DocumentsHelper, type: :helper do
  describe '#new_document_button' do
    context 'in dashboard' do
      before(:each) { allow(helper).to receive(:in_dashboard?).and_return(true) }

      context 'with permissions' do
        it 'should render the button' do
          expect(helper).to receive(:link_to).with(new_dashboard_document_path(protocol_id: 1), any_args)
          helper.new_document_button(permission: true, protocol_id: 1)
        end
      end

      context 'without permissions' do
        it 'should not render the button' do
          expect(helper.new_document_button(permission: false, protocol_id: 1)).to be_nil
        end
      end
    end

    context 'not in dashboard' do
      before(:each) { allow(helper).to receive(:in_dashboard?).and_return(false) }

      it 'should render the button' do
        expect(helper).to receive(:link_to).with(new_document_path(srid: 1), any_args)
        helper.new_document_button(srid: 1)
      end
    end
  end



  describe '#display_document_title' do
    let(:document) { create(:document) }

    context 'in dashboard' do
      before(:each) { allow(helper).to receive(:in_dashboard?).and_return(true) }

      context 'with permission' do
        it 'should render the title as a link' do
          expect(helper).to receive(:link_to).with(document.document_file_name, document.document.url, any_args)
          helper.display_document_title(document, permission: true)
        end
      end

      context 'without permission' do
        it 'should render the title as plain text' do
          expect(helper.display_document_title(document, permission: false)).to eq(document.document_file_name)
        end
      end
    end

    context 'not in dashboard' do
      before(:each) { allow(helper).to receive(:in_dashboard?).and_return(false) }

      it 'should render the title as a link' do
        expect(helper).to receive(:link_to).with(document.document_file_name, document.document.url, any_args)
        helper.display_document_title(document)
      end
    end
  end



  describe '#edit_document_button' do
    let(:document) { create(:document) }

    context 'in dashboard' do
      before(:each) { allow(helper).to receive(:in_dashboard?).and_return(true) }

      context 'with permissions' do
        it 'should render the button' do
          expect(helper).to receive(:link_to).with(anything, edit_dashboard_document_path(document), any_args)
          helper.edit_document_button(document, permission: true)
        end
      end

      context 'without permissions' do
        it 'should not render the button' do
          expect(helper.edit_document_button(document, permission: false)).to be_nil
        end
      end
    end

    context 'not in dashboard' do
      before(:each) { allow(helper).to receive(:in_dashboard?).and_return(false) }

      it 'should render the button' do
        expect(helper).to receive(:link_to).with(anything, edit_document_path(document, srid: 1), any_args)
        helper.edit_document_button(document, srid: 1)
      end
    end
  end



  describe '#delete_document_button' do
    let(:document) { create(:document) }

    context 'in dashboard' do
      before(:each) { allow(helper).to receive(:in_dashboard?).and_return(true) }

      context 'with permissions' do
        it 'should render the button' do
          expect(helper).to receive(:link_to).with(anything, dashboard_document_path(document), any_args)
          helper.delete_document_button(document, permission: true)
        end
      end

      context 'without permissions' do
        it 'should not render the button' do
          expect(helper.delete_document_button(document, permission: false)).to be_nil
        end
      end
    end

    context 'not in dashboard' do
      before(:each) { allow(helper).to receive(:in_dashboard?).and_return(false) }

      it 'should render the button' do
        expect(helper).to receive(:link_to).with(anything, document_path(document, srid: 1), any_args)
        helper.delete_document_button(document, srid: 1)
      end
    end
  end
end
