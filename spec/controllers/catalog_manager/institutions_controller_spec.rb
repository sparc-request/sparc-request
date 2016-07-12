require 'rails_helper'

RSpec.describe CatalogManager::InstitutionsController do
  let!(:logged_in_user) {create(:identity)}

  before :each do
    allow(controller).to receive(:authenticate_identity!).
      and_return(true)
    allow(controller).to receive(:current_identity).
      and_return(logged_in_user)
  end

  describe '#create' do
    before :each do
      post :create, name: 'Some Institution', format: :js
    end

    it 'should create an institution' do
      expect(Institution.count).to eq(1)
    end

    it 'should assign @organization' do
      expect(assigns(:organization)).to be_an_instance_of(Institution)
    end

    it 'should create a catalog_manager_rights' do
      expect(logged_in_user.catalog_manager_rights.count).to eq(1)
    end

    it { is_expected.to render_template "institutions/create" }
    it { is_expected.to respond_with :ok }
  end

  describe '#show' do
    before :each do
      @organization = create(:institution)
      logged_in_user.catalog_manager_rights.create( organization_id: @organization.id )

      xhr :get, :show, id: @organization.id
    end

    it 'should assign @path' do
      expect(assigns(:path)).to eq(catalog_manager_institution_path(@organization))
    end

    it 'should assign @organization' do
      expect(assigns(:organization)).to eq(@organization)
    end

    it { is_expected.to render_template "organizations/show" }
    it { is_expected.to respond_with :ok }
  end

  describe '#update' do
    before :each do
      @organization = create(:institution, name: 'Some Institution')
      logged_in_user.catalog_manager_rights.create( organization_id: @organization.id )
      pricing_setup = {id: '',
                       display_date:   '2016-06-27',
                       effective_date: '2016-06-28',
                       federal:   '100',
                       corporate: '100',
                       other:     '100',
                       member:    '100',
                       college_rate_type:      'federal',
                       federal_rate_type:      'federal',
                       foundation_rate_type:   'federal',
                       industry_rate_type:     'federal',
                       investigator_rate_type: 'federal',
                       internal_rate_type:     'federal',
                       unfunded_rate_type:     'federal',
                       newly_created: 'true'}
      @params = ActionController::Parameters.new(
                { id: @organization.id,
                  institution: { name: 'New Institution Name' },
                  pricing_setups: {blank_pricing_setup: pricing_setup} })

      xhr :put, :update, @params, format: :js
    end

    it 'should assign @attributes' do
      expect(assigns(:attributes)).to eq(@params[:institution])
    end

    it 'should assign @organization' do
      expect(assigns(:organization)).to eq(@organization)
    end

    it 'should update the organization' do
      @organization.reload
      expect(@organization.name).to eq(@params[:institution][:name])
    end

    it 'should not save pricing setups' do
      expect(@organization.pricing_setups.count).to eq(0)
    end

    it 'should not set organization tags' do
      expect(assigns(:attributes)[:tag_list]).to be_nil
    end

    it { is_expected.to render_template "organizations/update" }
    it { is_expected.to respond_with :ok }
  end
end