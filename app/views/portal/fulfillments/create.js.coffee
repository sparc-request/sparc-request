$("#one_time_fees").html("<%= escape_javascript(render(:partial => 'portal/sub_service_requests/one_time_fees')) %>");

for datepicker in $('.datepicker')
    do_datepicker("##{$(datepicker).attr('id')}")
