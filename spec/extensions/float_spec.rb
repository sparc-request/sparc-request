require 'spec_helper'
# require 'extensions/float'

describe 'Float' do
  context "testing decimal extension methods" do
    describe "floor_to" do
      it "should cut off any decimals after the number you pass in" do
        10.21341.floor_to(2).should eq(10.21)
      end

      it "should cut off any decimals after the number you pass in" do
        10.21341.floor_to(3).should eq(10.213)
      end

      it "should cut off any decimals after the number you pass in" do
        10.21.floor_to(3).should eq(10.210)
      end

      it "should cut off any decimals after the number you pass in" do
        10.2121212121.floor_to(8).should eq(10.21212121)
      end
    end
  end
end

