require "rails_helper"

RSpec.describe Dashboard::NotesController do
  describe "POST #create" do
    class MyNotableType
      attr_reader :id # instances of notable types should have an id
      def initialize(id) @id = id; end
      def self.find(id); end # notable types should respond to #find
      def notes; end # instance of notable types have Notes
    end

    context "params[:note][:body] empty" do
      before(:each) do
        @logged_in_user = build_stubbed(:identity)

        @notable_obj = findable_stub(MyNotableType) do
          MyNotableType.new(2)
        end
        allow(@notable_obj).to receive(:notes).and_return("all my notes")

        allow(Note).to receive(:create)

        log_in_dashboard_identity(obj: @logged_in_user)
        xhr :get, :create, note: { identity_id: "-1", notable_type: "MyNotableType",
          notable_id: "2", body: "" }
      end

      it "should not create a new Note" do
        expect(Note).not_to have_received(:create)
      end

      it "should assign @notes to notable object's Notes" do
        expect(assigns(:notes)).to eq("all my notes")
      end

      it { is_expected.to render_template "dashboard/notes/create" }
      it { is_expected.to respond_with :ok }
    end

    context "params[:note][:body] not empty" do
      before(:each) do
        @logged_in_user = build_stubbed(:identity)

        @notable_obj = findable_stub(MyNotableType) do
          MyNotableType.new(2)
        end

        @note = build_stubbed(:note)
        allow(@notable_obj).to receive(:notes).and_return("all my notes")

        allow(Note).to receive(:create).and_return(@note)

        log_in_dashboard_identity(obj: @logged_in_user)
        xhr :get, :create, note: { identity_id: "-1", notable_type: "MyNotableType",
          notable_id: "2", body: "this was notable" }
      end

      it "should create a new Note for current user with params[:note]" do
        expect(Note).to have_received(:create).with({
          identity_id: @logged_in_user.id,
          "notable_type" => "MyNotableType",
          "notable_id" => "2",
          "body" => "this was notable"
        })
      end

      it "should assign @note to the newly created Note" do
        expect(assigns(:note)).to eq(@note)
      end

      it "should assign @notes to notable object's Notes" do
        expect(assigns(:notes)).to eq("all my notes")
      end

      it { is_expected.to render_template "dashboard/notes/create" }
      it { is_expected.to respond_with :ok }
    end
  end
end
