require "rails_helper"

RSpec.describe Dashboard::LineItemsController do
  describe "PUT #update" do
    context "params[:line_item] is a valid update to LineItem" do
      before(:each) do
        @line_item = findable_stub(LineItem) { build_stubbed(:line_item) }
        allow(@line_item).to receive_message_chain(:service, :one_time_fee).
          and_return("am i a one time fee?")
        allow(@line_item).to receive(:update_attributes).and_return(true)

        log_in_dashboard_identity(obj: build_stubbed(:identity))
        xhr :put, :update, id: @line_item.id, line_item: "line item attributes"
      end

      it "should assign @otf to whether or not LineItem's Service is a one time fee" do
        expect(assigns(:otf)).to eq("am i a one time fee?")
      end

      it "should assign @line_item from params[:id]" do
        expect(assigns(:line_item)).to eq(@line_item)
      end

      it "should update attributes of LineItem from params[:id]" do
        expect(@line_item).to have_received(:update_attributes).
          with("line item attributes")
      end

      it "should not set @errors" do
        expect(assigns(:errors)).to be_nil
      end

      it { is_expected.to render_template "dashboard/line_items/update" }
      it { is_expected.to respond_with :ok }
    end

    context "params[:line_item] is not a valid update to a LineItem" do
      before(:each) do
        @line_item = findable_stub(LineItem) do
          build_stubbed(:line_item)
        end
        allow(@line_item).to receive(:errors).and_return("my errors")
        allow(@line_item).to receive_message_chain(:service, :one_time_fee).
          and_return("am i a one time fee?")
        allow(@line_item).to receive(:update_attributes).and_return(false)

        log_in_dashboard_identity(obj: build_stubbed(:identity))
        xhr :put, :update, id: @line_item.id, line_item: "line item attributes"
      end

      it "should assign @otf to whether or not LineItem's Service is a one time fee" do
        expect(assigns(:otf)).to eq("am i a one time fee?")
      end

      it "should assign @line_item from params[:id]" do
        expect(assigns(:line_item)).to eq(@line_item)
      end

      it "should update attributes of LineItem from params[:id]" do
        expect(@line_item).to have_received(:update_attributes).
          with("line item attributes")
      end

      it "should set @errors" do
        expect(assigns(:errors)).to eq("my errors")
      end

      it { is_expected.to render_template "dashboard/line_items/update" }
      it { is_expected.to respond_with :ok }
    end
  end
end
