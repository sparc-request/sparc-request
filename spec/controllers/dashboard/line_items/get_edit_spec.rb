require "rails_helper"

RSpec.describe Dashboard::LineItemsController do
  describe "GET #edit" do
    context "LineItem is a one time fee" do
      before(:each) do
        @line_item = findable_stub(LineItem) { build_stubbed(:line_item) }
        allow(@line_item).to receive_message_chain(:service, :one_time_fee).
          and_return(true)

        log_in_dashboard_identity(obj: build_stubbed(:identity))
        xhr :get, :edit, id: @line_item.id, modal: "my modal"
      end

      it "should assign @otf to whether or not LineItem's Service is a one time fee" do
        expect(assigns(:otf)).to eq(true)
      end

      it "should assign @header_text" do
        expect(assigns(:header_text)).not_to be_nil
      end

      it "should assign @line_item from params[:id]" do
        expect(assigns(:line_item)).to eq(@line_item)
      end

      it "should assign @modal_to_render to params[:modal]" do
        expect(assigns(:modal_to_render)).to eq("my modal")
      end

      it { is_expected.to render_template "dashboard/line_items/edit" }
      it { is_expected.to respond_with :ok }
    end

    context "LineItem is a not one time fee" do
      before(:each) do
        @line_item = findable_stub(LineItem) { build_stubbed(:line_item) }
        allow(@line_item).to receive_message_chain(:service, :one_time_fee).
          and_return(false)

        log_in_dashboard_identity(obj: build_stubbed(:identity))
        xhr :get, :edit, id: @line_item.id, modal: "my modal"
      end

      it "should assign @otf to whether or not LineItem's Service is a one time fee" do
        expect(assigns(:otf)).to eq(false)
      end

      it "should assign not @header_text" do
        expect(assigns(:header_text)).to be_nil
      end

      it "should assign @line_item from params[:id]" do
        expect(assigns(:line_item)).to eq(@line_item)
      end

      it "should assign @modal_to_render to params[:modal]" do
        expect(assigns(:modal_to_render)).to eq("my modal")
      end

      it { is_expected.to render_template "dashboard/line_items/edit" }
      it { is_expected.to respond_with :ok }
    end
  end
end
