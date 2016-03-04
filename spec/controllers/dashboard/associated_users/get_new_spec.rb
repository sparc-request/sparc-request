require 'rails_helper'

RSpec.describe Dashboard::AssociatedUsersController do
  describe 'GET new' do
    describe 'authorization' do
      context 'user not authorized to edit Protocol associated with ProjectRole' do
        it 'should render an error' do

        end
      end
    end

    it 'should set @identity to the Identity from params[:identity_id]' do

    end

    it 'should set @current_pi to the Primary PI of @protocol' do
    end

    it 'should set @project_role to a new ProjectRole associated with @protocol' do

    end

    it 'should set @header_text to "Add Associated User"' do
      
    end
  end
end
