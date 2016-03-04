require 'rails_helper'

RSpec.describe Dashboard::AssociatedUsersController do
  describe 'POST create' do
    describe 'authorization' do
      context 'user not authorized to edit Protocol associated with ProjectRole' do
        it 'should render an error' do

        end
      end
    end

    it 'should assign @protocol_role to new ProjectRole built from params[:project_role]' do

    end

    context 'params[:project_role][:role] == "primary-pi"' do
      it 'should change current Primary PI to a general access user with request rights' do

      end
    end

    it 'should set flash[:success]' do

    end

    context 'USE_EPIC == true and Protocol selected for epic' do
      it 'should notify about epic user approval' do

      end
    end

    context 'new ProjectRole not unique to Protocol' do
      it 'should set @errors to new ProjectRole\'s errors' do

      end
    end

    context 'new Projectole not fully valid' do
      it 'should set @errors to new ProjectRole\'s errors' do

      end
    end
  end
end
