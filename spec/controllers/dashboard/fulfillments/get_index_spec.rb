require "rails_helper"

RSpec.describe Dashboard::FulfillmentsController do
  describe "GET #index" do
    context "format js" do
      before(:each) do
        @line_item = findable_stub(LineItem) { build_stubbed(:line_item) }

        log_in_dashboard_identity(obj: build_stubbed(:identity))
        xhr :get, :index, line_item_id: @line_item.id
      end

      it "should assign LineItem from params[:line_item_id] to @line_item" do
        expect(assigns(:line_item)).to eq(@line_item)
      end

      it { is_expected.to render_template "dashboard/fulfillments/index" }
      it { is_expected.to respond_with :ok }
    end

    context "format json" do
      before(:each) do
        @line_item = findable_stub(LineItem) { build_stubbed(:line_item) }
        @fulfillments = instance_double(ActiveRecord::Relation)
        allow(@line_item).to receive(:fulfillments).and_return(@fulfillments)

        log_in_dashboard_identity(obj: build_stubbed(:identity))
        get :index, line_item_id: @line_item.id, format: :json
      end

      it "should assign LineItem from params[:line_item_id] to @line_item" do
        expect(assigns(:line_item)).to eq(@line_item)
      end

      it "should assign Fulfillments of LineItem to @fulfillments" do
        expect(assigns(:fulfillments)).to eq(@fulfillments)
      end

      it { is_expected.to render_template "dashboard/fulfillments/index" }
      it { is_expected.to respond_with :ok }
    end
  end
end
