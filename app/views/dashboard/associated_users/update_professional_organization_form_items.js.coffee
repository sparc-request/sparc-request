$('.professional-organization-form').html("<%= escape_javascript(render('dashboard/associated_users/professional_organizations', professional_organization: @professional_organization)) %>")
$('.professional-organization-form select').selectpicker()
