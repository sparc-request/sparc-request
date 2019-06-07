# Copyright © 2011-2019 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~


namespace :data do
  task :initialize_funding_related_permissible_values => :environment do

  puts "Adding new statuses into the permissible_values table:"
  #### Addtional statuses: Application Accepted, Application Rejected,Application Submitted,Deadline Missed (Application)
  ## 	Pre-Application/LOI  Accepted, Pre-Application/LOI Rejected, Pre-Application/LOI Submitted and Deadline Missed (Pre-Application/LOI)
  new_statuses = []
    app_accepted = PermissibleValue.create(
      key:           'app_accepted',
      value:         'Application Accepted',
      category:       'status',
      default:       0,
      sort_order:    21
    )
    new_statuses << app_accepted.value

    app_rejected = PermissibleValue.create(
      key:           'app_rejected',
      value:         'Application Rejected',
      category:       'status',
      default:       0,
      sort_order:    22
    )
    new_statuses << app_rejected.value

    app_submitted = PermissibleValue.create(
      key:           'app_submitted',
      value:         'Application Submitted',
      category:       'status',
      default:       0,
      sort_order:    23
    )
    new_statuses << app_submitted.value

    app_missed_deadline = PermissibleValue.create(
      key:           'app_missed_deadline',
      value:         'Deadline Missed (Application)',
      category:       'status',
      default:       0,
      sort_order:    24
    )
    new_statuses << app_missed_deadline.value

    loi_accepted = PermissibleValue.create(
      key:           'loi_accepted',
      value:         'Pre-Application/LOI  Accepted',
      category:       'status',
      default:       0,
      sort_order:    25
    )
    new_statuses << loi_accepted.value

    loi_rejected = PermissibleValue.create(
      key:           'loi_rejected',
      value:         'Pre-Application/LOI Rejected',
      category:       'status',
      default:       0,
      sort_order:    26
    )
    new_statuses << loi_rejected.value

    loi_submitted = PermissibleValue.create(
      key:           'loi_submitted',
      value:         'Pre-Application/LOI Submitted',
      category:       'status',
      default:       0,
      sort_order:    27
    )
    new_statuses << loi_submitted.value

    loi_missed_deadline = PermissibleValue.create(
      key:           'loi_missed_deadline',
      value:         'Deadline Missed (Pre-Application/LOI)',
      category:       'status',
      default:       0,
      sort_order:    28
    )
    new_statuses << loi_missed_deadline.value

    new_statuses.each { |x| puts x}
    puts


    puts "Adding new document types:"
    ### New Document Types: Application, Pre-application/Letter of Intents
    application = PermissibleValue.create(
      key:           'application',
      value:         'Application',
      category:       'document_type',
      sort_order:     0,
    )
    puts "#{application.value}"

    other_doc_type = PermissibleValue.where(category: 'document_type', key: 'other').first
    order = other_doc_type.sort_order

    loi = PermissibleValue.create(
      key:           'loi',
      value:         'Pre-Application/Letter of Intent',
      category:      'document_type',
      sort_order:    order,
    )
    puts "#{loi.value}"
    puts

    other_doc_type.update_attribute(:sort_order, 100)
    puts "The sort order for 'Other' is changed to 100."
  end
end
