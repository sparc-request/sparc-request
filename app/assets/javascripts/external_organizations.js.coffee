$(document).ready ->
  $(document).on 'changed.bs.select', '#external_organization_collaborating_org_name', '#protocol_external_organization_attributes_collaborating_org_name', ->

    if $(this).val() == 'other'
      $('#collaboratingOrgNameOtherContainer').removeClass('d-none')
    else
      $('#collaboratingOrgNameOtherContainer').addClass('d-none')

  $(document).on 'changed.bs.select', '#external_organization_collaborating_org_type', '#protocol_external_organization_attributes_collaborating_org_type', ->

    if $(this).val() == 'other'
      $('#collaboratingOrgTypeOtherContainer').removeClass('d-none')
    else
      $('#collaboratingOrgTypeOtherContainer').addClass('d-none')
