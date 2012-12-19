class Portal::DocumentsController < Portal::BaseController

  require 'open-uri'
  require 'base64'

  def download
    document = Document.find(params[:document_id])
    tempfile = open(document.url)
    send_data tempfile.read, :filename => document.title, :type => document.content_type
  end

  def override
    document_id = params[:document_id]
    document = params[:document]
    document_type = params[:document_type]
    ticket = Document.ticket(Alfresco::Document::ALFRESCO_USER, Alfresco::Document::ALFRESCO_PASSWORD)

    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.entry(:xmlns => "http://www.w3.org/2005/Atom",
                "xmlns:cmisra" => "http://docs.oasis-open.org/ns/cmis/restatom/200908/",
                "xmlns:cmis" => "http://docs.oasis-open.org/ns/cmis/core/200908/") {
        xml.title document.original_filename if document
        xml.summary document_type
        if document
          xml.content(:type => document.content_type) {
            xml.text Base64.encode64(document.read)
          }
        end
      }
    end

    url = Document::PATH + "cmis/i/#{document_id}?alf_ticket=" + ticket

    begin
      RestClient.put url, builder.to_xml, {:content_type => 'application/atom+xml;type=entry'}
    rescue => e
      Rails.logger.info "#"*50
      Rails.logger.info "Error updating file"
      Rails.logger.info e.message
      Rails.logger.info "#"*50
    end

    redirect_to :controller => 'related_service_requests', :action => 'show', :anchor => 'documents', :service_request_id => params[:friendly_id], :id => params[:ssr_id]
  end

  def upload
    document = params[:document]
    service_request_id = params[:service_request_id]
    organization_id = params[:organization_id]
    document_type = params[:document_type]

    # let's see how many existing docs we have before we upload
    document_count_before_upload = Alfresco::Document.number_of_documents_for(service_request_id)

    ticket = Document.ticket(Alfresco::Document::ALFRESCO_USER, Alfresco::Document::ALFRESCO_PASSWORD)

    builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
      xml.entry(:xmlns => "http://www.w3.org/2005/Atom",
                "xmlns:cmisra" => "http://docs.oasis-open.org/ns/cmis/restatom/200908/",
                "xmlns:cmis" => "http://docs.oasis-open.org/ns/cmis/core/200908/") {
        xml.title document.original_filename
        xml.summary document_type
        xml.content(:type => document.content_type) {
          xml.text Base64.encode64(document.read)
        }
      }
    end

    if !Document.service_request_folder_exists? service_request_id
      Document.create_service_request_folder service_request_id
    end

    sub_folders = Document.find_sub_folders_for_service_request service_request_id
    unless sub_folders.include? organization_id
      Document.create_service_request_organization_folder(service_request_id, organization_id)
    end

    url = Document::PATH + "cmis/p/User%20Homes/service_requests/#{service_request_id}/#{organization_id}/children?alf_ticket=" + ticket

    count = 0
    begin
      count = count + 1
      RestClient.post url, builder.to_xml, {:content_type => 'application/atom+xml;type=entry'}
    rescue => e
      Rails.logger.info "#"*50
      Rails.logger.info "Error creating file"
      Rails.logger.info e.message
      Rails.logger.info "#"*50
    end

    new_document_count = count + document_count_before_upload
    document_count_after_upload = Alfresco::Document.number_of_documents_for(service_request_id)

    while(document_count_after_upload != new_document_count) do
      sleep(0.5)
      document_count_after_upload = Alfresco::Document.number_of_documents_for(service_request_id)
    end

    redirect_to :controller => 'related_service_requests', :action => 'show', :anchor => 'documents', :service_request_id => params[:friendly_id], :id => params[:ssr_id]
  end

  def destroy
    document = Document.find(params[:id])
    document.destroy
    redirect_to :controller => 'related_service_requests', :action => 'show', :anchor => 'documents', :service_request_id => params[:friendly_id], :id => params[:ssr_id]
  end

end
