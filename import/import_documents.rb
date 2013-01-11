require 'progress_bar'
require 'bundler/setup'
require 'alfresco_handler'
require 'open-uri'
require 'rails'

require 'import'

ActiveRecord::Base.establish_connection(
    :adapter => 'mysql2',
    :host => 'localhost',   
    :database => 'sparc_development',  
    :username => 'sparc',
    :password => 'sparc',
) 

class ImportApplication < Rails::Application
  config.root = '../../sparc-rails'
end

ssrs = SubServiceRequest.all

bar = ProgressBar.new(ssrs.length)
SubServiceRequest.all.each do |ssr|
  ssr.documents.each do |doc|
    doc.destroy()
  end

  documents = Alfresco::Document.find_by_service_request_id_and_organization_id(ssr.service_request.obisid, ssr.organization.obisid)
  documents.each do |doc|
    # [#<Alfresco::Document:0x00000003ee3218 @id="c61ddd4f-d0fb-42b6-8511-840ac3f70f53", @title="12 9 11 Retreat Agenda (2) (2).docx", @enclosure="http://obis-sparc-alfresco-stg.mdc.musc.edu:8080/alfresco/service/cmis/s/workspace:SpacesStore/i/c61ddd4f-d0fb-42b6-8511-840ac3f70f53/content.docx", @document_type="protocol", @content_type="application/vnd.openxmlformats-officedocument.wordprocessingml.document", @updated_at=2012-05-07 15:52:39 -0400, @service_request_id="", @organization_id="87d1220c5abf9f9608121672be0e3ac1">]
    open(doc.url) do |file|
      file.singleton_class.instance_eval do
        define_method(:original_filename) { doc.title }
      end
      new_document = ssr.documents.create(
          doc_type: doc.document_type,
          document: file,
          document_content_type: doc.content_type,
          document_updated_at: doc.updated_at)
      new_document.create_document_grouping(
          service_request_id: ssr.id)
    end
  end
  bar.increment!
end

