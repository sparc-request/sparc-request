# Copyright © 2011-2022 MUSC Foundation for Research Development~
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

require 'rails_helper'

RSpec.describe CostAnalysis::TableWithGroupHeaders do

  describe "maintaining row counts" do
    it "should report indices for header rows" do

      subject.add_header []
      subject.add_data []
      subject.add_data []
      subject.add_summary []
      subject.add_header []
      subject.add_data []
      subject.add_summary []

      expect(subject.header_rows).to contain_exactly(0,4)
      expect(subject.summary_rows).to contain_exactly(3,6)
    end
  end

  context "when column labels are present" do

    before do
      subject.add_column_labels []
    end

    it "knows they are the first row" do
      subject.add_header []
      subject.add_data []
      subject.add_data []
      subject.add_summary []
      subject.add_header []
      subject.add_data []
      subject.add_summary []

      expect(subject.header_rows).to contain_exactly(1,5)
      expect(subject.summary_rows).to contain_exactly(4,7)
    end
  end

  describe "#table_rows" do
    it "has all rows" do
      subject.add_header ["A"]
      subject.concat([ ["C"], ["D"], ["E"] ])
      subject.add_summary ["Z"]

      expect(subject.table_rows).to contain_exactly(["A"],
                                                    ["C"],
                                                    ["D"],
                                                    ["E"],
                                                    ["Z"])
    end
  end

  describe '#split' do
    let(:row_tpl) { [:a,1,2,3,4,5, 6,7,8,9,10] }
    before do
      subject.add_data row_tpl
    end

    context 'keep 1 column and split in 2' do
      it 'creates 2 tables' do
        parts = subject.split(keep: 1,cols: 5)
        expect(parts).to have(2).items
        expect(parts[0].table_rows).to contain_exactly([:a,1,2,3,4,5])
        expect(parts[1].table_rows).to contain_exactly([:a,6,7,8,9,10])
      end
    end

    context 'keep 1 column but uneven split of 3' do
      it 'creates 4 tables' do
        parts = subject.split(keep: 1, cols: 3)
        expect(parts).to have(4).items
        expect(parts[0].table_rows).to contain_exactly([:a,1,2,3])
        expect(parts[1].table_rows).to contain_exactly([:a,4,5,6])
        expect(parts[2].table_rows).to contain_exactly([:a,7,8,9])
        expect(parts[3].table_rows).to contain_exactly([:a,10])
      end
    end

    context 'leading span column and data columns' do
      let(:row_tpl) { [{:colspan => 2},:a,:b,1,2,3,4] }
      it 'understands keep in context of colspan' do
        parts = subject.split(keep:4, cols: 2)
        expect(parts).to have(2).items
        expect(parts[0].table_rows).to contain_exactly([{:colspan => 2},:a,:b,1,2])
        expect(parts[1].table_rows).to contain_exactly([{:colspan => 2},:a,:b,3,4])
      end
    end
  end
end
