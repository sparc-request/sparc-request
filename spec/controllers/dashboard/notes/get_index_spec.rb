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

require "rails_helper"

RSpec.describe Dashboard::NotesController do
  describe "GET #index" do
    class MyNotableType
      attr_reader :id # instances of notable types should have an id
      def initialize(id) @id = id; end
      def self.find(id); end # notable types should respond to #find
      def notes; end # instance of notable types have Notes
    end

    before(:each) do
      @logged_in_user = build_stubbed(:identity)

      @notable_obj = findable_stub(MyNotableType) { MyNotableType.new(1) }
      allow(@notable_obj).to receive(:notes).and_return("all my notes")

      log_in_dashboard_identity(obj: @logged_in_user)
      xhr :get, :index, note: { notable_id: 1, notable_type: "MyNotableType" }
    end

    it "should set @notes to the notable object's Notes" do
      expect(assigns(:notes)).to eq("all my notes")
    end

    it "should set @notable to notable object" do
      expect(assigns(:notable)).to eq(@notable_obj)
    end

    it { is_expected.to render_template "dashboard/notes/index" }
    it { is_expected.to respond_with :ok }
  end
end
