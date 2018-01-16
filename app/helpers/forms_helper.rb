# Copyright © 2011-2017 MUSC Foundation for Research Development
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
  def form_completed_display(form, completed)
    klass = completed ? 'glyphicon glyphicon-ok text-success' : 'glyphicon glyphicon-remove text-danger'

    content_tag(:h4, content_tag(:span, '', class: klass))
  end

  def form_options(form, completed, respondable)
    if completed
      [ view_form_response_button(form),
        edit_form_response_button(form),
        delete_form_response_button(form)
      ].join('')
    else
      complete_form_response_button(form, respondable)
    end
  end

  def view_form_response_button(form)
    link_to(
      'View',
      '',
      remote: true,
      class: 'btn btn-info view-form'
    )
  end

  def edit_form_response_button(form)
    link_to(
      content_tag(:span, '', class: 'glyphicon glyphicon-edit', aria: { hidden: 'true' }),
      '',
      remote: true,
      class: 'btn btn-warning edit-form'
    )
  end

  def delete_form_response_button(form)
    link_to(
      content_tag(:span, '', class: 'glyphicon glyphicon-remove', aria: { hidden: 'true' }),
      '',
      remote: true,
      class: 'btn btn-danger edit-form'
    )
  end

  def complete_form_response_button(form, respondable)
    link_to(
      'Complete',
      new_surveyor_response_path(type: form.class.name, access_code: form.access_code, respondable_id: respondable.id, respondable_type: respondable.class.name),
      remote: true,
      class: 'btn btn-success view-form'
    )
  end
end
