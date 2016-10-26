# Copyright © 2011-2016 MUSC Foundation for Research Development
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
# require 'extensions/hash'

RSpec.describe 'Hash' do
  context "testing hash extension methods" do
    describe "reverse_hash_to_symbols" do
      it "should reverse the hash to symbols" do
        expect({text: '1234', more_text: "4321"}.reverse_hash_to_symbols).to eq({:"1234"=>"text", :"4321"=>"more_text"})
      end

      it "should reverse the hash to symbols" do
        expect({text: 'some_test_text', more_text: "some_more_test_text"}.reverse_hash_to_symbols).to eq({:some_test_text=>"text", :some_more_test_text=>"more_text"})
      end
    end

    describe "reverse_hash_to_strings" do
      it "should reverse the hash to strings" do
        expect({text: '1234', more_text: "4321"}.reverse_hash_to_strings).to eq({"1234"=>"text", "4321"=>"more_text"})
      end

      it "should reverse the hash to symbols" do
        expect({text: 'some_test_text', more_text: "some_more_test_text"}.reverse_hash_to_strings).to eq({"some_test_text"=>"text", "some_more_test_text"=>"more_text"})
      end
    end
  end
end
