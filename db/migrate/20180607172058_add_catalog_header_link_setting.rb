class AddCatalogHeaderLinkSetting < ActiveRecord::Migration[5.2]
  def change
    unless Setting.find_by_key('header_link_2_catalog')
      Setting.create(key: 'header_link_2_catalog', value: 'http://localhost:3000/catalog_manager', friendly_name: 'Header Logo 2 URL (SPARCCatalog)', description: 'The URL for the second image in the header logos in SPARCCatalog.', data_type: 'url')
    end
  end
end
