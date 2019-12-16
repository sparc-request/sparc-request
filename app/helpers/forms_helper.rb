# Copyright © 2011-2019 MUSC Foundation for Research Development
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

module FormsHelper
  def form_completed_display(completed)
    icon = completed ? icon('fas', 'check') : icon('fas', 'times')
    klass = completed ? 'text-success complete' : 'text-danger incomplete'

    content_tag(:h4, content_tag(:span, icon, class: klass))
  end

  def form_options(form, completed, respondable)
    if in_review?
      response = Response.where(survey: form, respondable: respondable).first
      response ? view_response_button(response) : link_to(icon('fas', 'eye'), 'javascript:void(0)', class: 'btn btn-info disabled')
    else
      if response = Response.where(survey: form, respondable: respondable).first
        content_tag :div, class: 'd-flex justify-content-center' do
          raw([ view_response_button(response),
            edit_response_button(response),
            delete_response_button(response)
          ].join(''))
        end
      else
        complete_form_button(form, respondable)
      end
    end
  end

  def complete_form_button(form, respondable)
    link_to(
      t(:actions)[:complete],
      new_surveyor_response_path(type: form.class.name, survey_id: form.id, respondable_id: respondable.id, respondable_type: respondable.class.name),
      remote: true,
      class: 'btn btn-success new-form-response',
      title: t(:surveyor)[:responses][:tooltips][:complete],
      data: { toggle: 'tooltip', placement: 'top', container: 'body', boundary: 'window' }
    )
  end
end
