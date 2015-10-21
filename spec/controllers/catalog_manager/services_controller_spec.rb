require 'rails_helper'

RSpec.describe CatalogManager::ServicesController, type: :controller do

  stub_catalog_manager_controller

  describe "#new" do

    context "success" do

      before { get :new, get_new_valid_params }

      it "should assign a new Service with default values" do
        expect(assigns(:service).name).to eq("New Service")
        expect(assigns(:service).abbreviation).to eq("New Service")
        expect(assigns(:service).organization_id).to eq(organization.id)
      end
    end
  end

  describe "#create" do

    context "success" do

      before(:each) { post :create, post_create_valid_params }

      it "should persist a Service" do
        expect(Service.count).to eq(1)
      end
    end
  end

  describe "#update" do

    context "success" do

      it "should update the Service" do
        service = create(:service)

        put :update, id: service.id, service: { name: "New name" }

        expect(service.reload.name).to eq("New name")
      end

      context "Service has no pre-existing ServiceLevelComponents" do

        it "should create ServiceLevelComponents" do
          service = create(:service)

          put :update, id: service.id, service: { name: "New name" }.merge!(service_level_component_params)

          expect(service.reload.components.split(',').count).to eq(2)
        end
      end

      context "Service has pre-existing ServiceLevelComponents" do

        before { @service = FactoryGirl.create(:service_with_components) }

        it "should create new ServiceLevelComponents" do
          put :update, id: @service.id, service: { name: "New name" }.merge!(service_level_component_params)

          expect(@service.reload.components.split(',').count).to eq(2)
        end

        it "should destroy ServiceLevelComponents marked for destroy" do
          service_level_component = @service.components.split(',').first

          put :update, id: @service.id, service: service_level_component_destroy_params(@service, service_level_component)

          expect(@service.reload.components.split(',').count).to eq(2)
        end
      end
    end

    describe "#show" do

      context "Service with pre-existing ServiceLevelComponents" do

        it "should build ServiceLevelComponents with the correct :position" do
          service = FactoryGirl.create(:service_with_components, organization: organization)

          get :show, id: service.id

          expect(assigns(:service).components.split(',').count).to eq(3)
        end
      end
    end
  end

  def service_level_component_destroy_params(service, component)
    {
      components: (service.components.split(',') - [component]).join(',')
    }
  end

  def service_level_component_params
    {
      components: "ServiceLevelComponent 1,ServiceLevelComponent 2,"
    }
  end

  def post_create_valid_params
    {
      service: {
        program: organization.id,
        core: 0,
        name: "New Service",
        abbreviation: "New Service",
        description: "xxx",
        order: 1,
        is_available: true,
        one_time_fee: false,
        components: "ServiceLevelComponent 1,ServiceLevelComponent 2,",
        cpt_code: "",
        charge_code: "",
        revenue_code: "",
        send_to_epic: 0
      },
      pricing_maps: {
        blank_pricing_map: {
          display_date: "2015-04-22",
          effective_date: "2015-04-29",
          full_rate: "123.00",
          federal_rate: "",
          corporate_rate: "",
          other_rate: "",
          member_rate: "",
          unit_type: "Per Infusion",
          unit_factor: 1,
          unit_minimum: 1,
          otf_unit_type: "N/A",
          quantity_type: "",
          quantity_minimum: 1,
          units_per_qty_max: 1
        }
      }
    }
  end

  def get_new_valid_params
    {
      parent_id: organization.id,
      parent_object_type: "program"
    }
  end

  def organization
    @organization ||= create(:program_with_provider)
  end
end
