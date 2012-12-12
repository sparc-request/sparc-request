require 'date'
require 'spec_helper'

describe 'Protocol' do
  describe 'funding_source_based_on_status' do
    it 'should return the potential funding source if funding status is pending_funding' do
      protocol = Protocol.create(FactoryGirl.attributes_for(:protocol))
      protocol.funding_status = 'pending_funding'
      protocol.funding_source = 'college'
      protocol.potential_funding_source = 'foundation'
      protocol.funding_source_based_on_status.should eq 'foundation'
    end

    it 'should return the funding source if funding status is funded' do
      protocol = Protocol.create(FactoryGirl.attributes_for(:protocol))
      protocol.funding_status = 'funded'
      protocol.funding_source = 'college'
      protocol.potential_funding_source = 'foundation'
      protocol.funding_source_based_on_status.should eq 'college'
    end

    it 'should raise an exception if funding status is nil' do
      protocol = Protocol.create(FactoryGirl.attributes_for(:protocol))
      protocol.funding_status = nil
      lambda { protocol.funding_source_based_on_status }.should raise_exception ArgumentError
    end

    it 'should raise an exception if funding status is neither funded nor pending_funding' do
      protocol = Protocol.create(FactoryGirl.attributes_for(:protocol))
      protocol.funding_status = 'foobarbaz'
      lambda { protocol.funding_source_based_on_status }.should raise_exception ArgumentError
    end
  end
end
 
