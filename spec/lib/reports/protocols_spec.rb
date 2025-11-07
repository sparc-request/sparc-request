require 'rails_helper'

RSpec.describe ProtocolsReport do
  let!(:protocol) { create(:protocol_without_validations) }

  context 'when \'include additional funding source columns\' is checked' do
    it 'should show additional funding source column in the report' do
      params = {
        show_additional_funding_source_cols: '1'
      }
      report = ProtocolsReport.new(params)
      cols = report.column_attrs.keys

      expect(cols).to include("Additional Funding Source(s)")
    end
  end

  context 'when \'include external organization columns\' is checked' do
    it 'should show external organization column in the report' do
      params = {
        show_external_organization_cols: '1'
      }
      report = ProtocolsReport.new(params)
      cols = report.column_attrs.keys

      expect(cols).to include("External Organization(s)")
    end
  end
end
