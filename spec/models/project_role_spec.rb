require 'spec_helper'

describe "Project Role" do

  let!(:user)         {FactoryGirl.create(:identity)}
  let!(:user2)         {FactoryGirl.create(:identity)}
      
  before :each do
    @protocol = Study.create(FactoryGirl.attributes_for(:protocol))
    @protocol.save(validate: false)
    @project_role = FactoryGirl.create(:project_role, protocol_id: @protocol.id, identity_id: user.id)
  end

  describe "validate uniqueness within protocol" do

    it "should return false if the user is already associated with a given protocol" do
      @project_role.validate_uniqueness_within_protocol.should eq(false)
    end

    it "should return true if the user is not already associated with a given protocol" do
      project_role = FactoryGirl.build(:project_role, protocol_id: @protocol.id)
      project_role.validate_uniqueness_within_protocol.should eq(true)
    end
  end

  describe "validate one primary pi" do
    
    it "should return true if project role has at least one pi" do
      @project_role.validate_one_primary_pi.should eq(true)
    end

    it "should return false if no primary pi exists" do
      @project_role.update_attributes(role: 'mentor')
      @project_role.validate_one_primary_pi.should eq(false)
    end
  end

  describe "is only primary pi" do

    let!(:project_role) {FactoryGirl.create(:project_role, protocol_id: @protocol.id, role: 'mentor')}
    
    it "should return true if only one project role has a pi on the protocol" do
      @project_role.is_only_primary_pi?.should eq(true)
    end

    it "should return false if more than one project role has a pi associated with the protocol" do
      project_role.update_attributes(role: 'primary-pi')
      @project_role.is_only_primary_pi?.should eq(false)
    end
  end

  describe "can switch to" do

    it "should return false if current user is on project role and right == 'none' or 'view'" do
      @project_role.can_switch_to?('none', user).should eq(false)
    end

    it "should return true if current user is on project role and right == 'request' and role != 'pi'" do
      @project_role.update_attributes(role: 'mentor')
      @project_role.can_switch_to?('request', user).should eq(true)
    end

    it "should return false if right == 'none' or 'view' or 'request', and role == 'pi'" do
      @project_role.can_switch_to?('none',    user2).should eq(false)
      @project_role.can_switch_to?('view',    user2).should eq(false)
      @project_role.can_switch_to?('request', user2).should eq(false)
    end

    it "should return true if previous conditions are not met" do
      @project_role.update_attributes(role: 'mentor')
      @project_role.can_switch_to?('none',   user2).should eq(true)
      @project_role.can_switch_to?('approve', user).should eq(true)
    end
  end

  describe "should select" do

    it "should return true if project rights == right" do
      @project_role.update_attributes(project_rights: 'approve')
      @project_role.should_select?('approve', user).should eq(true)
    end

    it "should return true if role == 'pi' and right == 'approve'" do
      @project_role.should_select?('approve', user).should eq(true)
    end

    it "should return true if current user is on project role, role != 'pi', and right == 'request'" do
      @project_role.update_attributes(role: 'mentor')
      @project_role.should_select?('request', user).should eq(true)
    end

    it "should return false if previous conditions are not met" do
      @project_role.should_select?('request', user).should eq(false)
      @project_role.update_attributes(role: 'mentor')
      @project_role.should_select?('request', user2).should eq(false)
    end
  end

  describe "display rights" do

    it "should display 'Member Only' when project right is 'none'" do
      @project_role.update_attributes(project_rights: 'none')
      @project_role.display_rights.should eq("Member Only")
    end

    it "should display 'View Rights' when project right is 'view'" do
      @project_role.update_attributes(project_rights: 'view')
      @project_role.display_rights.should eq("View Rights")
    end

    it "should display 'Request/Approve Services' when project right is 'request'" do
      @project_role.update_attributes(project_rights: 'request')
      @project_role.display_rights.should eq("Request/Approve Services")
    end

    it "should display 'Authorize/Change Study Charges' when project right is 'approve'" do
      @project_role.update_attributes(project_rights: 'approve')
      @project_role.display_rights.should eq("Authorize/Change Study Charges")
    end

  end
end
