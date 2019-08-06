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
