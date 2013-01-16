require 'date'
require 'spec_helper'

describe 'Protocol' do
  describe 'funding_source_based_on_status' do
    it 'should return the potential funding source if funding status is pending_funding' do
      study = Study.create(FactoryGirl.attributes_for(:protocol))
      study.funding_status = 'pending_funding'
      study.funding_source = 'college'
      study.potential_funding_source = 'foundation'
      study.funding_source_based_on_status.should eq 'foundation'
    end

    it 'should return the funding source if funding status is funded' do
      study = Study.create(FactoryGirl.attributes_for(:protocol))
      study.funding_status = 'funded'
      study.funding_source = 'college'
      study.potential_funding_source = 'foundation'
      study.funding_source_based_on_status.should eq 'college'
    end
  end

  describe 'should validate funding status and source for studies' do
    it 'should raise an exception if funding status is nil' do
      study = Study.create(FactoryGirl.attributes_for(:protocol))
      study.funding_status = nil
      lambda { study.funding_source_based_on_status }.should raise_exception ArgumentError
    end

    it 'should raise an exception if funding status is neither funded nor pending_funding' do
      study = Study.create(FactoryGirl.attributes_for(:protocol))
      study.funding_status = 'foobarbaz'
      lambda { study.funding_source_based_on_status }.should raise_exception ArgumentError
    end
  end
  
  describe 'should validate funding source for projects' do
    it 'should raise an exception if funding source is nil' do
      project = Project.create(FactoryGirl.attributes_for(:protocol))
      project.funding_source = nil
      project.valid?.should eq false
    end
  end
end
 
