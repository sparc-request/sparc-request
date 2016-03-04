require 'rails_helper'

RSpec.describe Dashboard::AssociatedUsersController do
  describe 'GET show' do
    describe 'authorization' do
      context 'user not authorized to view Protocol associated with ProjectRole' do
        it 'should render an error' do

        end
      end
    end

    it 'should set @protocol_role to ProjectRole of user (described by params[:id]) associated with Protocol' do

    end

    it 'should set @user to Identity of @project_role' do
      
    end
  end
end
