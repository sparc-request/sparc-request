$(document).ready ->

  $(document).on('change', '.clinical_data', ->
    $('.study_tracker_table').hide()
    $("#appointment_form.object.visit_group.#{$(this).val()}").show()
    console.log $(this).val()
  )