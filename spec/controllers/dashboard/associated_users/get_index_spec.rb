require 'rails_helper'

RSpec.describe Dashboard::AssociatedUsersController do
  describe 'GET index' do
    describe 'authorization' do
      context 'user not authorized to view Protocol associated with ProjectRole' do
        it 'should render an error' do

        end
      end
    end

    it 'should set @protocol from params[:protocol_id] when present' do

    end

    it 'should set @protocol from params[:project_role][protocol_id] when present' do
    end

    it 'should set @permission_to_edit' do

    end

    it 'should set @protocol_roles to Protocol\'s ProjectRoles' do
      
    end
  end
end
