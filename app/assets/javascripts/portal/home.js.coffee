# Copyright © 2011 MUSC Foundation for Research Development
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

# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

$(document).ready ->
  $('.btn').button()

  Sparc.home = {
    
    handle_ajax_errors: (errors_array, entity_type) ->
      errors_array = JSON.parse(errors_array)
      error_string = ""
      error_number = 0
      for key,value of errors_array
        for error in value
          error_number += 1
          error_string += "<li>#{key[0].toUpperCase()}#{key.substr(1, key.length - 1)} #{error}</li>"
   
      $('.errorExplanation').html("<h2>#{error_number} error(s) prevented this #{entity_type} from being saved:</h2>
        <p>There were problems with the following fields:</p>
        <ul>
          #{error_string}
        </ul>
      ").show()
    
    getInfo: (info, force=null) ->
      spinner = $(".#{info}-spinner")
      if (spinner.length > 0) or (force is 'force')
        spinner.show()
        sr_id  = $('.service-request-id').val()
        ssr_id = $('.sub-service-request-id').val()
        $.ajax
          method: 'get'
          url   : "/portal/admin/service_requests/#{sr_id}/related_service_requests/#{ssr_id}/#{info}"
          success: ->
            $('.date').datepicker
              constrainInput: true
              dateFormat: "m/dd/yy"
              changeMonth: true
              changeYear: true
              showButtonPanel: true
              beforeShow: (input) ->
                callback = ->
                  buttonPane = $(input).datepicker( "widget" ).find( ".ui-datepicker-buttonpane" )
                  $( "<button>", {
                    class: "ui-state-default ui-priority-primary ui-corner-all"
                    text: "Clear"
                    click: ->
                      $.datepicker._clearDate(input)
                  }).appendTo(buttonPane)
                setTimeout( callback, 1)
              
            $('.date').attr("readOnly", true)
            spinner.remove()
  }

  $('#study_tracker_tabs').tabs
    active: ($.cookie("study_tracker_tab_name"))
    activate: (event, ui) ->
      idx = ui.newTab.parent().children().index(ui.newTab)
      $.cookie("study_tracker_tab_name", idx, { expires: 1 })


  $('.tabs').tabs
    active: ($.cookie("admin_tab_name"))
    show: (event, ui) ->
      class_name = ui.tab.className
      switch class_name
        when 'documents-tab'                 then Sparc.home.getInfo('documents')
        when 'associated_users-tab'          then Sparc.home.getInfo('associated_users')
        when 'notifications-tab'             then Sparc.home.getInfo('notifications')
        when 'project-tab'                   then Sparc.home.getInfo('project')
        when 'related_service_requests-tab'  then Sparc.home.getInfo('related_service_requests')
        when 'clinical_work_fulfillment-tab' then Sparc.home.getInfo('clinical_work_fulfillment')
        when 'fulfillment-tab'
          Sparc.home.getInfo('service_request_info')
          Sparc.home.getInfo('add_service')
          Sparc.home.getInfo('notifications_area')
          Sparc.home.getInfo('service_request_status_changes')
          Sparc.home.getInfo('service_request_approval_changes')
          Sparc.home.getInfo('service_request_information')
          Sparc.home.getInfo('one_time_fees')
          Sparc.home.getInfo('per_patient_services')
    activate: (event, ui) ->
      idx = ui.newTab.parent().children().index(ui.newTab)
      $.cookie("admin_tab_name", idx, { expires: 1 })

