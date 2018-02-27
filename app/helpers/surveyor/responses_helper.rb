# Copyright © 2011-2018 MUSC Foundation for Research Development
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

module Surveyor::ResponsesHelper

  def complete_display(response)
    klass = response.completed? ? 'glyphicon glyphicon-ok text-success' : 'glyphicon glyphicon-remove text-danger'

    content_tag(:h4, content_tag(:span, '', class: klass))
  end

  def response_options(response)
    [ view_response_button(response),
      edit_response_button(response),
      download_response_button(response)
    ].join('')
  end

  def view_response_button(response)
    link_to(
      t(:actions)[:view],
      surveyor_response_path(response),
      remote: true,
      class: 'btn btn-info view-Ffresponse'
    )
  end

  def edit_response_button(response)
    link_to(
      content_tag(:span, '', class: 'glyphicon glyphicon-edit', aria: { hidden: 'true' }),
      edit_surveyor_response_path(response),
      remote: true,
      class: 'btn btn-warning edit-response'
    )
  end

  def delete_response_button(response)
    content_tag(:button,
      content_tag(:span, '', class: 'glyphicon glyphicon-remove', aria: { hidden: 'true' }),
      data: { response_id: response.id },
      class: 'btn btn-danger delete-response'
    )
  end

  def download_response_button(response)
    link_to(
      content_tag(:span, '', class: 'glyphicon glyphicon-download-alt', aria: { hidden: 'true' }),
      'javascript:void(0)',
      remote: true,
      class: 'btn btn-success download-response'
    )
  end

  def dependency_classes(question)
    if question.is_dependent?
      ["dependent-for-option-#{question.depender_id}",
      "dependent-for-question-#{question.depender.question_id}",
      "hidden"].join(' ')
    else
      ""
    end
  end

  def survey_data(question)
    if question.is_dependent?
      {
        depender_id: question.depender_id,
        depender_question_id: question.depender.question_id
      }
    end
  end

  def multiple_select_formatter(content)
    content.tr("[]\"", "").split(',').map(&:strip)
  end
end
