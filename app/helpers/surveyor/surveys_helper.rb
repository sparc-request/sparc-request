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

module Surveyor::SurveysHelper
  ### Surveys Table ###
  def survey_active_display(survey)
    klass = survey.active? ? 'glyphicon glyphicon-ok text-success' : 'glyphicon glyphicon-remove text-danger'

    content_tag(:h4, content_tag(:span, '', class: klass))
  end

  def survey_options(survey)
    [ edit_survey_button(survey),
      delete_survey_button(survey),
      activate_survey_button(survey),
      preview_survey_button(survey)
    ].join('')
  end

  def edit_survey_button(survey)
    content_tag(:button,
      raw(
        content_tag(:span, '', class: 'glyphicon glyphicon-edit', aria: { hidden: 'true' })
      ),
      title: t(:surveyor)[:surveys][:table][:fields][:edit],
      data: { survey_id: survey.id, toggle: 'tooltip', animation: 'false' },
      class: 'btn btn-warning edit-survey'
    )
  end

  def delete_survey_button(survey)
    content_tag(:button,
      raw(
        content_tag(:span, '', class: 'glyphicon glyphicon-remove', aria: { hidden: 'true' })
      ),
      title: t(:surveyor)[:surveys][:table][:fields][:delete],
      data: { survey_id: survey.id, toggle: 'tooltip', animation: 'false' },
      class: 'btn btn-danger delete-survey'
    )
  end

  def activate_survey_button(survey)
    text = survey.active? ? t(:surveyor)[:surveys][:table][:fields][:disable] : t(:surveyor)[:surveys][:table][:fields][:activate]
    klass = survey.active? ? 'btn-danger activate-survey' : 'btn-success disable-survey'
    
    link_to text, surveyor_survey_updater_path(survey, klass: 'survey', survey: { active: !survey.active }), method: :patch, remote: true, class: ['btn', klass]
  end

  def preview_survey_button(survey)
    content_tag(:button,
      raw(
        content_tag(:span, '', class: 'glyphicon glyphicon-search', aria: { hidden: 'true' })+
        t(:surveyor)[:surveys][:table][:fields][:preview]
      ),
      data: { survey_id: survey.id },
      class: 'btn btn-info preview-survey'
    )
  end

  ### Surveys Form ###
  def display_order_options
    options_from_collection_for_select(
      Survey.all,
      'display_order',
      'insertion_name'
    )+
    content_tag(
      :option,
      t(:constants)[:add_as_last],
      value: Survey.order('display_order DESC').first.display_order+1
    )
  end

  def add_section_content
    raw(
      [ content_tag(:span, '', class: 'glyphicon glyphicon-th-list'),
        t(:surveyor)[:surveys][:form][:content][:section][:add]
      ].join("")
    )
  end

  def add_question_content
    raw(
      [ content_tag(:span, '', class: 'glyphicon glyphicon-plus'),
        t(:surveyor)[:surveys][:form][:content][:question][:add]
      ].join("")
    )
  end
end
