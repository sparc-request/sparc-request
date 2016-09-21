# Copyright © 2011-2016 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

module CapybaraSupport

  def create_default_data
    identity = Identity.create(
      last_name:             'Glenn',
      first_name:            'Julia',
      ldap_uid:              'jug2@musc.edu',
      institution:           'medical_university_of_south_carolina',
      college:               'college_of_medecine',
      department:            'other',
      email:                 'glennj@musc.edu',
      credentials:           'BS,    MRA',
      catalog_overlord:      true,
      password:              'p4ssword',
      password_confirmation: 'p4ssword',
      approved:              true
      )
    identity.save!

    institution = create(:institution,
      name:                 'Medical University of South Carolina',
      order:                1,
      abbreviation:         'MUSC',
      is_available:         1)
    institution.save!

    cm = CatalogManager.create(
      organization_id:      institution.id,
      identity_id:          identity.id,
      edit_historic_data: true
    )
    cm.save!

    provider = create(:provider,
      name:                 'South Carolina Clinical and Translational Institute (SCTR)',
      order:                1,
      css_class:            'blue-provider',
      parent_id:            institution.id,
      abbreviation:         'SCTR1',
      process_ssrs:         0,
      is_available:         1)
    provider.save!

    service_provider = create(:service_provider,
      identity_id:          identity.id,
      organization_id:               provider.id)
    service_provider.save!

    provider_subsidy_map = SubsidyMap.create(
      organization_id:      provider.id,
      max_dollar_cap:       121.0000,
      max_percentage:       12.00
    )
    provider_subsidy_map.save!

    program = create(:program,
      type:                 'Program',
      name:                 'Office of Biomedical Informatics',
      order:                1,
      description:          'The Biomedical Informatics Programs goal is to integrate..',
      parent_id:            provider.id,
      abbreviation:         'Informatics',
      process_ssrs:         0,
      is_available:         1)
    program.save!

    subsidy_map = SubsidyMap.create(
      organization_id:      program.id,
      max_dollar_cap:       121.0000,
      max_percentage:       12.00
    )
    subsidy_map.save!

    core = create(:core,
      type:                 'Core',
      name:                 'Clinical Data Warehouse',
      order:                1,
      parent_id:            program.id,
      abbreviation:         'Clinical Data Warehouse')
    core.save!

    core_subsidy_map = SubsidyMap.create(
      organization_id:      core.id,
      max_dollar_cap:       121.0000,
      max_percentage:       12.00
    )
    core_subsidy_map.save!

    program_service_pricing_map = create(:pricing_map,
      display_date:                 Date.yesterday,
      effective_date:               Date.yesterday,
      unit_type:                    'Per Query',
      unit_factor:                  1,
      quantity_type:                'Each',
      quantity_minimum:             5,
      otf_unit_type:                'Week',
      full_rate:                    4500.0000,
      exclude_from_indirect_cost:   0,
      unit_minimum:                 1,
      unit_type:                    'self')
    program_service_pricing_map.save!

    program_service = create(:service,
      name:                 'Human Subject Review',
      abbreviation:         'HSR',
      order:                1,
      cpt_code:             '',
      organization_id:      program.id,
      is_available:         true,
      one_time_fee:         1,
      pricing_maps:         [program_service_pricing_map])
    program_service.save!

    service_pricing_map = create(:pricing_map,
      display_date:                 Date.yesterday,
      effective_date:               Date.yesterday,
      unit_type:                    'Per Query',
      unit_factor:                  1,
      quantity_type:                'Each',
      quantity_minimum:             5,
      otf_unit_type:                'Week',
      full_rate:                    4500.0000,
      exclude_from_indirect_cost:   0,
      unit_minimum:                 1,
      unit_type:                    'self')
    service_pricing_map.save!

    service = create(:service,
      name:                 'MUSC Research Data Request (CDW)',
      abbreviation:         'CDW',
      order:                1,
      cpt_code:             '',
      organization_id:      core.id,
      one_time_fee:         1,
      pricing_maps:         [service_pricing_map])
    service.save!


    pricing_setup = create(:pricing_setup,
      organization_id:              program.id,
      display_date:                 Date.today,
      effective_date:               Date.today,
      college_rate_type:            'full',
      federal_rate_type:            'full',
      foundation_rate_type:         'full',
      industry_rate_type:           'full',
      investigator_rate_type:       'full',
      internal_rate_type:           'full',
      unfunded_rate_type:           'full')
    pricing_setup.save!

    project = FactoryGirl.create(:protocol_without_validations)

    service_request = FactoryGirl.create(:service_request_without_validations, protocol_id: project.id, status: "draft", subject_count: 2)

    sub_service_request = create(:sub_service_request, service_request_id: service_request.id, organization_id: program.id,status: "draft", service_requester_id: Identity.find_by_ldap_uid("jug2@musc.edu").id)

    arm = create(:arm, protocol_id: project.id, subject_count: 2, visit_count: 10)

    line_items_visit = create(:line_items_visit, arm_id: arm.id, subject_count: arm.subject_count)

    survey = create(:survey, title: "System Satisfaction survey", description: nil, access_code: "system-satisfaction-survey", reference_identifier: nil,
                                         data_export_identifier: nil, common_namespace: nil, common_identifier: nil, active_at: nil, inactive_at: nil, css_url: nil,
                                         custom_class: nil, created_at: "2013-07-02 14:40:23", updated_at: "2013-07-02 14:40:23", display_order: 0, api_id: "4137bedf-40db-43e9-a411-932a5f6d77b7",
                                         survey_version: 0)

  end

  def create_ctrc_data
    provider = Provider.first

    program = create(:program,
      type:                 'Program',
      name:                 'Clinical and Translational Research Center (CTRC)',
      order:                2,
      description:          'The CTRC goal is to integrate..',
      parent_id:            provider.id,
      abbreviation:         'CTRC',
      process_ssrs:         1,
      is_available:         1)
    program.save!

    subsidy_map = SubsidyMap.create(
      organization_id:      program.id,
      max_dollar_cap:       50000.0000,
      max_percentage:       50.00
    )
    subsidy_map.save!

    core = create(:core,
      type:                 'Core',
      name:                 'Nursing',
      order:                1,
      parent_id:            program.id,
      abbreviation:         'Nursing')
    core.save!

    core_service_pricing_map = create(:pricing_map,
      display_date:                 Date.yesterday,
      effective_date:               Date.yesterday,
      unit_type:                    'Each',
      unit_factor:                  1,
      full_rate:                    4500.0000,
      exclude_from_indirect_cost:   0,
      unit_minimum:                 1,
      unit_type:                    'Each')
    core_service_pricing_map.save!

    core_service = create(:service,
      name:                 'Venipuncture',
      abbreviation:         'VPR',
      order:                1,
      cpt_code:             '',
      organization_id:      core.id,
      is_available:         true,
      pricing_maps:         [core_service_pricing_map])
    core_service.save!
  end

  def default_catalog_manager_setup
    create_default_data
    login_as(Identity.find_by_ldap_uid('jug2@musc.edu'))
    ## Logs in the default identity.
    visit catalog_manager_root_path
    ## This is used to reveal all nodes in the js tree to make it easier to access during testing.
    page.execute_script("$('#catalog').find('.jstree-closed').attr('class', 'jstree-open');")
  end

  def increase_wait_time(seconds)
    orig_seconds = seconds
    begin
      Capybara.default_max_wait_time = seconds
    ensure
      Capybara.default_max_wait_time = orig_seconds
    end
  end

  # Following two methods used for adding and deleting catalog managers, service providers, etc. in spec/features/catalog_manger/shared_spec.rb
  def add_first_identity_to_organization(field)
    sleep 3
    fill_in "#{field}", with: "bjk7"
    wait_for_javascript_to_finish
    page.find('a', text: "Brian Kelsey (kelsey@musc.edu)", visible: true).click()
    wait_for_javascript_to_finish
    first("#save_button").click
    wait_for_javascript_to_finish
  end
  def add_identity_to_organization(field)
    sleep 3
    fill_in "#{field}", with: "leonarjp"
    wait_for_javascript_to_finish
    page.find('a', text: "Jason Leonard (leonarjp@musc.edu)", visible: true).click()
    wait_for_javascript_to_finish
    first("#save_button").click
    wait_for_javascript_to_finish
  end

  def delete_identity_from_organization(field, delete)
    wait_for_javascript_to_finish
    add_identity_to_organization("#{field}")
    if field == "new_sp"
      add_first_identity_to_organization("#{field}")
    end
    # This overrides the javascript confirm dialog
    page.evaluate_script('window.confirm = function() { return true; }')
    first("#{delete}").click
    wait_for_javascript_to_finish
  end

  def visit_email email
    driver = Capybara::Email::Driver.new(email)
    node = Capybara::Node::Email.new(Capybara.current_session, driver)
    Capybara.current_session.driver.visit "file://#{node.save_page}"
  end

  def get_mail sr_id, ssr_id, role = 'service provider'
    #returns email from notifier based on situation provided/desired.
    sr =  ServiceRequest.find(service_request.id)
    ssr = SubServiceRequest.find(sub_service_request.id)
    #Assumes current identity is id=1
    user = Identity.find(1)

    case role
    when 'service provider'
      xls = []
      previously_submitted_at = sr.submitted_at.nil? ? Time.now.utc : sr.submitted_at.utc
      audit =  ssr.audit_report(user, previously_submitted_at, Time.now.utc)
      sp = ssr.organization.service_providers.where("(`service_providers`.`hold_emails` != 1 OR `service_providers`.`hold_emails` IS NULL)")[0]
      return Notifier.notify_service_provider(sp,sr,xls,user,audit)

    when 'user'
      xls = " "
      project_role = sr.protocol.project_roles.select{ |role| role.project_rights != 'none' and !role.identity.email.blank? }[0]
      approval = service_request.approvals.create
      return Notifier.notify_user(project_role,sr,xls,approval,user)

    when 'admin'
      xls = " "
      sub_email = 'success@musc.edu'
      return Notifier.notify_admin(sr,sub_email,xls,user)
    end
    return nil
  end

  def visit_mail_for role
    #role options include ['service provider', 'admin', 'user']
    email = get_mail(service_request.id, sub_service_request.id, role)
    if email.nil?
      return nil
    elsif email.multipart?
      visit_email email.html_part
    else
      visit_email email
    end
  end
end

RSpec.configure do |config|
  config.include CapybaraSupport
end
