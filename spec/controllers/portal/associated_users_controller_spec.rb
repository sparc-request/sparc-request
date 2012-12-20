require 'spec_helper'

describe Portal::AssociatedUsersController do
  # include EntityHelpers
  #
  # render_views
  #
  # before(:each) do
  #   @protocol = make_project :short_title => "Obvious Waste of Taxpayer Dollars"
  #   @user = make_user :first_name => "Gunnels", :last_name => "Marcus", :email => "chester@wester.bear"
  #   @new_user = make_user :first_name => "Cates", :last_name => "Andronicus", :email => "catesa@musc.edu"
  #   attach_user_to_project(@user, @protocol, 'pi')
  # end
  #
  # describe "SHOW protocol/:id/associated_users/" do
  #
  #   it "should get the appropriate associated users" # do
  #    #          get 'show', :id => @protocol['id'], :protocol_id => @protocol['id'], :protocol => @protocol, :user => @user
  #    #        end
  #
  # end
  #
  # describe "GET protocol/:id/associated_users/new" do
  #   it "should attach the correct project on new" do
  #     get 'new', :protocol_id => @protocol['id']
  #     assigns[:protocol].id.should eq(@protocol['id'])
  #   end
  # end
  #
  # describe "POST protocol/:id/associated_users/" do
  #
  #   describe "with valid params" do
  #
  #     before(:each) do
  #       post 'create', :protocol_id => @protocol['id'], :associated_user => @new_user
  #     end
  #
  #     it "should create the associated user relationship" do
  #       assigns[:rel]['relationship_type'].should eq('project_role')
  #       assigns[:rel]['attributes']['last_name'].should eq(@new_user['last_name'])
  #       assigns[:rel]['from'].should eq(@protocol['id'])
  #       assigns[:rel]['to'].should eq(@new_user['id'])
  #       JSON.parse(RestClient.get("http://localhost:4567/obisentity/projects/#{@protocol['id']}/relationships")).count.should eq(2)
  #     end
  #
  #     it "should fix the booleans" do
  #       assigns[:rel]['attributes']['view_only_rights'].should be_false
  #       assigns[:rel]['attributes']['req_app_services'].should_not eq("false")
  #     end
  #
  #   end
  #
  # end
  #
  # describe "PUT protocol/:id/associated_users/:id" do
  #
  #   describe "with valid params" do
  #
  #     before(:each) do
  #       pr_id = JSON.parse(RestClient.get("http://localhost:4567/obisentity/projects/#{@protocol['id']}/relationships")).first['relationship_id']
  #       put 'update', :protocol_id => @protocol['id'], :id => @user['id'], :associated_user => {:pr_id => pr_id, :subspecialty => '3421', :auth_change_study => 'true'}
  #     end
  #
  #     it "should update the associated user" do
  #       assigns[:rel]['attributes']['subspecialty'].should eq('3421')
  #       JSON.parse(RestClient.get("http://localhost:4567/obisentity/projects/#{@protocol['id']}/relationships")).count.should eq(1)
  #     end
  #
  #     it "should fix the booleans" do
  #       assigns[:rel]['attributes']['view_only_rights'].should eq(false)
  #       assigns[:rel]['attributes']['req_app_services'].should_not eq("false")
  #     end
  #
  #     it "should change the proxy rights" do
  #       assigns[:rel]['attributes']['auth_change_study'].should eq(true)
  #     end
  #
  #   end
  #
  # end
  #
  # describe "DELETE protocol/:id/associated_users/:id" do
  #
  #   it "should delete the associated user relationship" do
  #     pr_id = JSON.parse(RestClient.get("http://localhost:4567/obisentity/projects/#{@protocol['id']}/relationships")).first['relationship_id']
  #     delete 'destroy', :protocol_id => @protocol['id'], :id => pr_id
  #     JSON.parse(RestClient.get("http://localhost:4567/obisentity/projects/#{@protocol['id']}/relationships")).count.should eq(0)
  #   end
  #
  # end

end
