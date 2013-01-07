require 'pstore'
require 'fileutils'
require 'json'
require 'open-uri'
require 'mustache'
require 'ostruct'
require 'rest_client'
require 'cgi'

require 'active_support/core_ext/object/blank'

require_relative 'annotate'

ORIG_PORT = 4567
NEW_PORT = 4568

ENTITY_TYPES = [
  'identities',
  'institutions',
  'providers',
  'programs',
  'cores',
  'projects',
  'studies',
  'services',
  'service_requests',
  'organizational_units',
]

def get_json(uri)
  annotate("retrieving json from #{uri}") do
    data = open(uri) { |file| file.read() }
    json = JSON.parse(data)
    return json
  end
end

def obis_common_entity_type(entity_type)
  if entity_type == 'studies' then
    obis_common_entity_type = 'projects'
  else
    obis_common_entity_type = entity_type
  end

  return obis_common_entity_type
end

class ObisQuery
  attr_reader :query_type
  attr_reader :all_query
  attr_reader :obisid_query
  attr_reader :rid_query
  attr_reader :compare_func

  def initialize(h)
    @query_type    = h[:query_type]
    @all_query     = h[:all_query]
    @post_query    = h[:post_query]
    @obisid_query  = h[:obisid_query]
    @rid_query     = h[:rid_query]
    @compare_func  = h[:compare_func]
  end

  def get_all_entities(entity_type)
    FileUtils.mkdir_p('cache')

    filename = "cache/#{@query_type}.#{entity_type}.db"

    if File.exists?(filename) then
      entities = File.open(filename) { |io| Marshal.load(io) }
    else
      uri = Mustache.render(
          @all_query,
          port:        ORIG_PORT,
          entity_type: obis_common_entity_type(entity_type))
      entities = get_json(uri)
      File.open(filename, 'w') { |io| io.write(Marshal.dump(entities)) }
    end

    return entities
  end

  def get_orig(entity_type, id)
    orig_uri = Mustache.render(
        @obisid_query,
        port:        ORIG_PORT,
        entity_type: obis_common_entity_type(entity_type),
        obisid:      id)
    return get_json(orig_uri)
  end

  def get_new(entity_type, id)
    new_uri = Mustache.render(
        @obisid_query,
        port:        NEW_PORT,
        entity_type: entity_type,
        obisid:      id)
    new = get_json(new_uri)
  end

  def get_orig_rel(entity_type, id, rid)
    new_uri = Mustache.render(
        @rid_query,
        port:        ORIG_PORT,
        entity_type: entity_type,
        obisid:      id,
        rid:         rid)
    new = get_json(new_uri)
  end

  def get_new_rel(entity_type, id, rid)
    new_uri = Mustache.render(
        @rid_query,
        port:        NEW_PORT,
        entity_type: entity_type,
        obisid:      id,
        rid:         rid)
    new = get_json(new_uri)
  end

  def delete_new(entity_type, id)
    new_uri = Mustache.render(
        @obisid_query,
        port:        NEW_PORT,
        entity_type: entity_type,
        obisid:      id)
    begin
      annotate("sending DELETE to uri #{new_uri}") do
        RestClient.delete(new_uri)
      end
    rescue RestClient::Exception
      raise RuntimeError, $!.message
    end
  end

  def post_new(entity_type, h)
    new_uri = Mustache.render(
        @post_query,
        port:        NEW_PORT,
        entity_type: entity_type)
    annotate("sending POST to #{new_uri} with body #{h.to_json}") do
      begin
        RestClient.post(new_uri, h.to_json, :content_type => 'application/json')
      rescue RestClient::Exception
        raise RuntimeError, $!.message
      end
    end
  end

  def put_new(entity_type, id, h)
    new_uri = Mustache.render(
        @obisid_query,
        port:        NEW_PORT,
        entity_type: entity_type,
        obisid:      id)
    annotate("sending PUT to #{new_uri} with body #{h.to_json}") do
      begin
        RestClient.put(new_uri, h.to_json, :content_type => 'application/json')
      rescue RestClient::Exception
        raise RuntimeError, $!.message
      end
    end
  end

  def put_new_rel(entity_type, id, rid, h)
    new_uri = Mustache.render(
        @rid_query,
        port:        NEW_PORT,
        entity_type: entity_type,
        obisid:      id,
        rid:         rid)
    annotate("sending PUT to #{new_uri} with body #{h.to_json}") do
      begin
        RestClient.put(new_uri, h.to_json, :content_type => 'application/json')
      rescue RestClient::Exception
        raise RuntimeError, $!.message
      end
    end
  end

  def post_new_rel(entity_type, id, h)
    new_uri = Mustache.render(
        @rid_query,
        port:        NEW_PORT,
        entity_type: entity_type,
        obisid:      id)
    annotate("sending POST to #{new_uri} with body #{h.to_json}") do
      begin
        RestClient.post(new_uri, h.to_json, :content_type => 'application/json')
      rescue RestClient::Exception
        raise RuntimeError, $!.message
      end
    end
  end
end

def fix_legacy_date(s)
  case s
  when nil, ''                                                                                  
    return nil                                                                                  
                                                                                                
  when /(\d+)-(\d+)-(\d+)/                                                                      
    yyyy = $1.to_i                                                                              
    mm = $2.to_i                                                                                
    dd = $3.to_i                                                                                
                                                                                                
    # workaround for a bug in the time picker                                                   
    # this isn't a perfect workaround                                                           
    if mm < 3 and yyyy <= 2012 then                                                             
      mm += 10                                                                                  
    elsif mm == 0 then                                                                          
      mm += 10                                                                                  
    end                                                                                         
                                                                                                
    date = Date.new(yyyy, mm, dd)                                                               
    return date.strftime('%Y-%m-%d')
                                                                                                
  else                                                                                          
    return s
  end                                                                                           
end

def prepare_line_items(line_items)
  line_items.each do |line_item|
    line_item['complete_date'] = fix_legacy_date(line_item['complete_date'])
    line_item['in_process_date'] = fix_legacy_date(line_item['in_process_date'])
    line_item['is_one_time_fee'] ||= false
    line_item.delete('complete_date')         if line_item['complete_date'] == '' or line_item['complete_date'].nil?
    line_item.delete('in_process_date')       if line_item['in_process_date'] == '' or line_item['in_process_date'].nil?
    line_item.delete('subject_count')         if line_item['subject_count'].nil?
    line_item.delete('visit_count')           if line_item['visit_count'].nil?
    line_item['fulfillment'] ||= [ ]
    line_item['fulfillment'].each do |fulfillment|
      fulfillment['date'] = fix_legacy_date(fulfillment['date'])
      fulfillment.delete('date') if fulfillment['date'].nil? or fulfillment['date'] == ''
    end
    line_item['visits'] ||= [ ]
    line_item['visits'].each do |visit|
      visit.delete('created_at')
      visit.delete('updated_at')
      visit.delete('id')
    end
  end
end

def prepare_service_request(service_request)
  service_request['start_date'] = fix_legacy_date(service_request['start_date'])
  service_request['end_date'] = fix_legacy_date(service_request['end_date'])
  service_request['requester_contacted_date'] = fix_legacy_date(service_request['requester_contacted_date'])
  service_request['consult_arranged_date'] = fix_legacy_date(service_request['consult_arranged_date'])
  service_request.delete('subject_count')             if service_request['subject_count'].nil?
  service_request.delete('visit_count')               if service_request['visit_count'].nil?
  service_request.delete('pppv_complete_date')        if service_request['pppv_complete_date'] == ''
  service_request.delete('pppv_in_process_date')      if service_request['pppv_in_process_date'] == ''
  service_request.delete('end_date')                  if service_request['end_date'] == '' or service_request['end_date'].nil?
  service_request.delete('start_date')                if service_request['start_date'] == '' or service_request['start_date'].nil?
  service_request.delete('requester_contacted_date')  if service_request['requester_contacted_date'] == '' or service_request['requester_contacted_date'].nil?
  service_request.delete('consult_arranged_date')     if service_request['consult_arranged_date'] == '' or service_request['consult_arranged_date'].nil?
  service_request['subsidies'] ||= { }
  if service_request['approval_data'].nil? or service_request['approval_data'][0].nil? then
    service_request['approval_data'] = [ { 'approvals' => { }, 'charges' => { }, 'tokens' => { } } ]
  end
  service_request['approval_data'] = [ service_request['approval_data'][0] ] # TODO: what do we do about the elements beyond index 0?
  service_request['sub_service_requests'].each do |ssr_id, ssr|
    if ssr['past_statuses'] then
      ssr['past_statuses'].each do |past_status|
        if past_status[1] then
          past_status[1] = Time.parse(past_status[1]).localtime.strftime('%Y-%m-%d %H:%M:%S')
        end
      end
    end
  end
  if service_request['line_items'] then
    prepare_line_items(service_request['line_items'])
  end
end

def prepare_project(project)
  project.delete('_type')
  project.delete('potential_funding_source_other') if project['potential_funding_source_other'].blank?
  project.delete('funding_source_other')           if project['funding_source_other'].blank?
  project.delete('service_requests')
  project.delete('users')
  project.delete('f_non_phs_sponsor')
  project.delete('f_phs_sponsor')
  project.delete('hr_number')                     if project['hr_number'] == ''
  project.delete('iacuc_approval_date')           if project['iacuc_approval_date'] == ''
  project.delete('iacuc_expiration_date')         if project['iacuc_expiration_date'] == ''
  project.delete('iacuc_number')                  if project['iacuc_number'] == '' or project['iacuc_number'].nil?
  project.delete('ide_number')                    if project['ide_number'] == ''
  project.delete('ind_number')                    if project['ind_number'] == ''
  project.delete('ind_on_hold')                   if project['ind_on_hold'] == false
  project.delete('inventors')                     if project['inventors'] == ''
  project.delete('irb_approval_date')             if project['irb_approval_date'] == ''
  project.delete('irb_expiration_date')           if project['irb_expiration_date'] == ''
  project.delete('irb_of_record')                 if project['irb_of_record'] == ''
  project.delete('name_of_iacuc')                 if project['name_of_iacuc'] == ''
  project.delete('p_funding_start')               if project['p_funding_start'] == ''
  project.delete('patent_number')                 if project['patent_number'] == ''
  project.delete('pro_number')                    if project['pro_number'] == ''
  project.delete('submission_type')               if project['submission_type'] == ''
  project.delete('funding_start_date')            if project['funding_start_date'] == ''
  project.delete('potential_funding_start_date')  if project['potential_funding_start_date'] == ''
  project.delete('display_date')                  if project['display_date'] == ''
  project.delete('sponsor_name')                  if project['sponsor_name'] == ''
  project.delete('federal_grant_serial_number')   if project['federal_grant_serial_number'] == ''
  project.delete('federal_grant_title')           if project['federal_grant_title'] == ''
  project.delete('federal_grant_code_id')         if project['federal_grant_code_id'] == ''
  project.delete('federal_phs_sponsor')           if project['federal_phs_sponsor'] == ''
  project.delete('federal_non_phs_sponsor')       if project['federal_non_phs_sponsor'] == ''
  project.delete('funding_rfa')                   if project['funding_rfa'].blank?
  project.delete('hr_number')                     if project['hr_number'].blank?
  project.delete('udak_project_number')           if project['udak_project_number'].blank?
  project.delete('brief_description')             if project['brief_description'].blank?
  project.delete('sponsor_name')                  if project['sponsor_name'].nil?

  project['affiliations'] ||= { }
  project['affiliations'].delete('lipidomics_cobre')      if project['affiliations']['lipidomics_cobre'] == false
  project['affiliations'].delete('inbre')                 if project['affiliations']['inbre'] == false
  project['affiliations'].delete('oral_health_cobre')     if project['affiliations']['oral_health_cobre'] == false
  project['affiliations'].delete('cardiovascular_cobre')  if project['affiliations']['cardiovascular_cobre'] == false
  project['affiliations'].delete('cancer_center')         if project['affiliations']['cancer_center'] == false
  project['affiliations'].delete('reach')                 if project['affiliations']['reach'] == false
  project['affiliations'].delete('cchp')                  if project['affiliations']['cchp'] == false

  project['research_types'] ||= { }
  project['research_types'].delete('human_subjects')            if project['research_types']['human_subjects'] == false
  project['research_types'].delete('vertebrate_animals')        if project['research_types']['vertebrate_animals'] == false
  project['research_types'].delete('investigational_products')  if project['research_types']['investigational_products'] == false
  project['research_types'].delete('ip_patents')                if project['research_types']['ip_patents'] == false

  project['impact_areas'] ||= { }
  project['impact_areas'].delete('diabetes')      if project['impact_areas']['diabetes'] == false
  project['impact_areas'].delete('hiv_aids')      if project['impact_areas']['hiv_aids'] == false
  project['impact_areas'].delete('hypertension')  if project['impact_areas']['hypertension'] == false
  project['impact_areas'].delete('pediatrics')    if project['impact_areas']['pediatrics'] == false
  project['impact_areas'].delete('stroke')        if project['impact_areas']['stroke'] == false
  project['impact_areas'].delete('cancer')        if project['impact_areas']['cancer'] == false

  project['study_types'] ||= { }
  project['study_types'].delete('translational_science')  if project['study_types']['translational_science'] == false
  project['study_types'].delete('clinical_trials')        if project['study_types']['clinical_trials'] == false
  project['study_types'].delete('basic_science')          if project['study_types']['basic_science'] == false

  if not project['research_types']['human_subjects'] then
    project.delete('hr_number')
    project.delete('irb_approval_date')
    project.delete('irb_expiration_date')
    project.delete('irb_of_record')
    project.delete('pro_number')
    project.delete('submission_type')
  end

  if not project['research_types']['vertebrate_animals'] then
    project.delete('iacuc_approval_date')
    project.delete('iacuc_expiration_date')
    project.delete('iacuc_number')
    project.delete('name_of_iacuc')
  end
end

def prepare_new_entity(entity)
  entity['attributes'].delete('subspecialty') # too hard to test
end

def prepare_identity(entity)
  entity['attributes'].delete('admin')
  entity['attributes'].delete('credentials_other')
  entity['attributes'].delete('other_credentials')
  entity['attributes'].delete('subspecialty') # too hard to test
  entity['attributes'].delete('email') if entity['attributes']['email'].nil?
  entity['identifiers']['email'] = entity['attributes']['email'] if entity['attributes']['email']
  entity['identifiers']['ldap_uid'] = "#{entity['identifiers']['ldap_uid']}@musc.edu" if entity['identifiers']['ldap_uid']
  entity['attributes']['uid'] = "#{entity['attributes']['uid']}@musc.edu" if entity['attributes']['uid']
end

def prepare_organization(entity)
  entity['attributes']['submission_emails'] ||= [ ]
  # entity['attributes']['subsidy_map'] ||= {"max_percentage"=>nil, "max_dollar_cap"=>nil, "excluded_funding_sources"=>[]}
  entity['attributes'].delete('subsidy')
  entity['attributes'].delete('edit_historic_data')
  entity['attributes'].delete('pricing_setups')
  entity['attributes'].delete('css_class') if entity['attributes']['css_class'].nil?
  entity['attributes']['order'] = Integer(entity['attributes']['order']) if not entity['attributes']['order'].nil?
  entity['attributes']['is_available'] ||= false
end

def prepare_service(entity)
  entity['attributes'].delete('subsidy') # deprecated
  entity['attributes'].delete('line_items') # service requests have line items, not services
  if entity['attributes']['pricing_maps'] then
    entity['attributes']['pricing_maps'].each do |pricing_map|
      pricing_map.delete('exclude_from_indirect_cost') if pricing_map['exclude_from_indirect_cost'].nil?
      pricing_map.delete('display_date') if pricing_map['display_date'].blank?
    end
  end
  entity['attributes'].delete('is_available') # TODO: to check this, we need to have access to the organization
end

def prepare_entity(entity)
  annotate("while preparing entity: #{entity.pretty_inspect}") do
    entity.delete('_rev')

    if entity['classes'].include?('identity') then
      prepare_identity(entity)

    elsif entity['classes'].include?('core') or
          entity['classes'].include?('institution') or
          entity['classes'].include?('provider') or
          entity['classes'].include?('program') then
      prepare_organization(entity)

    elsif entity['classes'].include?('project') or
          entity['classes'].include?('study') then
      if not entity['attributes']['friendly_id'] then
        entity['attributes']['friendly_id'] = entity['identifiers']['project_id']
      end
      prepare_project(entity['attributes'])

    elsif entity['classes'].include?('service') then
      prepare_service(entity)

    elsif entity['classes'].include?('service_request')
      prepare_service_request(entity['attributes'])
      if not entity['attributes']['friendly_id'] then
        entity['attributes']['friendly_id'] = entity['identifiers']['service_request_id']
      end

    end
  end
end

def prepare_relationship(rel)
  rel.delete('_id')
  rel.delete('_rev')
  rel.delete('relationship_id')
  rel.delete('created_at')

  case rel['relationship_type']
  when 'project_role'
    rel['attributes'].delete('subspecialty')
    rel['attributes'].delete('pr_id')
    rel['attributes'].delete('role_other')
    rel['attributes']['id'] = rel['to'] if rel['attributes']['id'].nil?

  when 'service_provider_organizational_unit'
    rel['attributes'] ||= { }
    rel['attributes'].delete('view_draft_status')
    rel['attributes']['is_primary_contact'] ||= false
    rel['attributes']['hold_emails'] ||= false
    # rel['attributes']['submission_emails'] ||= [ ]

  when 'catalog_manager_organizational_unit'
    rel['attributes'] ||= { }
    rel['attributes']['edit_historic_data'] ||= false

  end

end

def sort_relationships!(relationships)
  relationships.sort! { |rel1, rel2|
    a1 = [ rel1['relationship_type'], rel1['from'], rel1['to'], rel1.sort ]
    a2 = [ rel2['relationship_type'], rel2['from'], rel2['to'], rel2.sort ]
    a1 <=> a2
  }
end

def relationship_type_counts(rels)
  counts = { }
  for rel in rels do
    type = rel['relationship_type']
    counts[type] ||= 0
    counts[type] += 1
  end
  return counts
end

def compare_relationship_types(orig, new)
  annotate("comparing #{orig.pretty_inspect} and #{new.pretty_inspect}") do
    orig_counts = relationship_type_counts(orig)
    new_counts  = relationship_type_counts(new)
    orig_counts.compare(new_counts)
  end
end

