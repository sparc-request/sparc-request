require 'spec_helper'
require 'extensions/hash'

describe 'Hash' do
  context "testing hash extension methods" do
    describe "reverse_hash_to_symbols" do
      it "should reverse the hash to symbols" do
        {:text => '1234', :more_text => "4321"}.reverse_hash_to_symbols.should eq({:"1234"=>"text", :"4321"=>"more_text"})
      end

      it "should reverse the hash to symbols" do
        {:text => 'some_test_text', :more_text => "some_more_test_text"}.reverse_hash_to_symbols.should eq({:some_test_text=>"text", :some_more_test_text=>"more_text"})
      end
    end

    describe "reverse_hash_to_strings" do
      it "should reverse the hash to strings" do
        {:text => '1234', :more_text => "4321"}.reverse_hash_to_strings.should eq({"1234"=>"text", "4321"=>"more_text"})
      end

      it "should reverse the hash to symbols" do
        {:text => 'some_test_text', :more_text => "some_more_test_text"}.reverse_hash_to_strings.should eq({"some_test_text"=>"text", "some_more_test_text"=>"more_text"})
      end
    end
  end
end

