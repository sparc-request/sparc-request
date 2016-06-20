require "rails_helper"

RSpec.describe Dashboard::NotesController do
  describe "GET #new" do
    class MyNotableType
      attr_reader :id # instances of notable types should have an id
      def initialize(id) @id = id; end
      def self.find(id); end # notable types should respond to #find
      def notes; end # instance of notable types have Notes
    end

    before(:each) do
      @logged_in_user = build_stubbed(:identity)
      @notable_obj = findable_stub(MyNotableType) do
        MyNotableType.new(2)
      end

      allow(Note).to receive(:new).and_return("my new note")

      log_in_dashboard_identity(obj: @logged_in_user)
      xhr :get, :new, note: { identity_id: "-1", notable_type: "MyNotableType",
        notable_id: "2", body: "very important note" }
    end

    it "should assign @note to newly created Note" do
      expect(assigns(:note)).to eq("my new note")
    end

    it "should create a new Note with params[:note] and identity_id: current_user.id merged" do
      expect(Note).to have_received(:new).
        with({
          identity_id: @logged_in_user.id,
          "notable_type" => "MyNotableType",
          "notable_id" => "2",
          "body" => "very important note"
        })
    end

    it { is_expected.to render_template "dashboard/notes/new" }
    it { is_expected.to respond_with :ok }
  end
end
