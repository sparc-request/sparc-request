require 'rails_helper'

RSpec.describe AdditionalDetails::QuestionnairesController do

  describe '#new' do
    it 'should instantiate a new Questionnaire object' do
      service = create(:service)

      get :new, service_id: service

      expect(assigns(:questionnaire).class).to eq Questionnaire
    end
    it 'should instantiate a new Questionnaire object' do
      service = create(:service)

      get :new, service_id: service

      expect(assigns(:questionnaire).new_record?).to eq true
    end
  end

  describe '#edit' do
    it 'should return the correct Questionnaire' do
      service = create(:service)
      questionnaire = create(:questionnaire)

      get :edit, service_id: service, id: questionnaire

      expect(assigns(:questionnaire)).to eq questionnaire
    end

    it 'should return the correct Questionnaire' do
      service = create(:service)
      questionnaire = create(:questionnaire)

      get :edit, service_id: service, id: questionnaire

      expect(response).to render_template :edit
    end
  end

  describe '#create' do
    context 'success' do
      it 'should create a new Questionnaire record' do
        service = create(:service)

        expect{ post :create, service_id: service, questionnaire: {
          'name'=>'string', :items_attributes=>{ '0'=>{'content'=>'test', 'item_type'=>'text', 'required'=>'1'} }
        }}.to change{ Questionnaire.count }.by(1)
      end
      it 'should create a new Item record' do
        service = create(:service)

        expect{ post :create, service_id: service, questionnaire: {
          'name'=>'string', :items_attributes=>{ '0'=>{'content'=>'test', 'item_type'=>'text', 'required'=>'1'} }
        }}.to change{ Item.count }.by(1)
      end
      it 'should redirect to the index action' do
        service = create(:service)

        post :create, service_id: service, questionnaire: {
          'name'=>'string', :items_attributes=>{ '0'=>{'content'=>'test', 'item_type'=>'text', 'required'=>'1'} }
        }

        expect(response).to redirect_to action: :index, service_id: service.id
      end
    end
    context 'unsuccessful' do
      it 'should render the new template' do
        service = create(:service)

        post :create, service_id: service, questionnaire: {
          :items_attributes=>{ '0'=>{'content'=>'test'} }
        }

        expect(response).to render_template :new
      end
      it 'should not create a new Questionnaire record' do
        service = create(:service)

        expect{ post :create, service_id: service, questionnaire: {
          :items_attributes=>{ '0'=>{'content'=>'test'} }
        }}.not_to change{ Questionnaire.count }
      end
      it 'should not create a new Item record' do
        service = create(:service)

        expect{ post :create, service_id: service, questionnaire: {
          :items_attributes=>{ '0'=>{'content'=>'test'} }
        }}.not_to change{ Item.count }
      end
    end
  end

  describe '#update' do
    it 'should redirect to #index' do
      service = create(:service)
      questionnaire = create(:questionnaire, service: service)
      create(:item, questionnaire: questionnaire)

      patch :update, service_id: service, id: questionnaire, questionnaire: {
        "name"=>"#{questionnaire.name}", :items_attributes=>{ '0'=>{'content'=>'testy',
                                                                    'item_type'=>'text', 'required'=>'1'}
      }
      }

      expect(response).to redirect_to action: :index, service_id: service
    end
    it 'should render edit on validation error' do
      service = create(:service)
      questionnaire = create(:questionnaire, service: service)
      create(:item, questionnaire: questionnaire)

      patch :update, service_id: service, id: questionnaire, questionnaire: {
        "name"=>"#{questionnaire.name}", :items_attributes=>{ '0'=>{'content'=>'',
                                                                    'item_type'=>'text', 'required'=>'1'}
      }
      }

      expect(response).to render_template :edit
    end
  end

  describe '#destroy' do
    it 'should destroy the requested object' do
      service = create(:service)
      questionnaire = create(:questionnaire, service: service)

      expect{ delete :destroy, service_id: service, id: questionnaire}.to change{ Questionnaire.count }.by(-1)
    end

    it 'should destroy dependent objects' do
      service = create(:service)
      questionnaire = create(:questionnaire, service: service)
      create(:item, questionnaire: questionnaire)

      expect{ delete :destroy, service_id: service, id: questionnaire}.to change{ Item.count }.by(-1)
    end
    it 'should destroy dependent objects' do
      service = create(:service)
      questionnaire = create(:questionnaire, service: service)
      create(:item, questionnaire: questionnaire)

      delete :destroy, service_id: service, id: questionnaire

      expect(response).to redirect_to action: :index, service_id: service
    end
  end
end

