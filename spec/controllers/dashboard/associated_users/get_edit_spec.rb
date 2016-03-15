require 'rails_helper'

RSpec.describe Dashboard::AssociatedUsersController do
  describe 'GET edit' do
    describe 'authorization' do
      context 'user not authorized to edit Protocol associated with ProjectRole' do
        it 'should render an error' do

        end
      end
    end
    
    it 'should set @project_role from params[:id]' do

    end

    it 'should set @protocol from @project_role.protocol' do

    end

    it 'should set @identity to the Identity associated with @project_role' do

    end

    it 'should set @current_pi to the Primary PI of @protocol' do
    end

    it 'should set @header_text to "Edit Authorized User"' do

    end
  end
end
