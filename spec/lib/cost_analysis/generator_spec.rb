require 'rails_helper'
require 'pdf/inspector'

RSpec.describe CostAnalysis::Generator do

  let(:pi) { create(:identity) }
  let(:protocol) { create(:protocol_federally_funded, primary_pi: pi) }

  it 'should render into a pdf' do
    doc = Prawn::Document.new(:page_layout => :landscape)
    subject.protocol = protocol
    subject.to_pdf(doc)
    pdf_text = PDF::Inspector::Text.analyze(doc.render)
    expect(pdf_text.strings).to include(match(/CRU Protocol#: [0-9]+/))
  end
end
