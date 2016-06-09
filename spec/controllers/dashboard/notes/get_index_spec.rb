require "rails_helper"

RSpec.describe Dashboard::NotesController do
  describe "GET #index" do
    class MyNotableType
      attr_reader :id # instances of notable types should have an id
      def initialize(id) @id = id; end
      def self.find(id); end # notable types should respond to #find
      def notes; end # instance of notable types have Notes
    end

    before(:each) do
      @logged_in_user = build_stubbed(:identity)

      @notable_obj = findable_stub(MyNotableType) { MyNotableType.new(1) }
      allow(@notable_obj).to receive(:notes).and_return("all my notes")

      log_in_dashboard_identity(obj: @logged_in_user)
      xhr :get, :index, note: { notable_id: 1, notable_type: "MyNotableType" }
    end

    it "should set @notes to the notable object's Notes" do
      expect(assigns(:notes)).to eq("all my notes")
    end

    it "should set @notable to notable object" do
      expect(assigns(:notable)).to eq(@notable_obj)
    end

    it { is_expected.to render_template "dashboard/notes/index" }
    it { is_expected.to respond_with :ok }
  end
end
