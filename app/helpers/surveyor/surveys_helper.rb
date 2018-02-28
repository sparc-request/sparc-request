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
    link_to(
      content_tag(:span, '', class: 'glyphicon glyphicon-edit', aria: { hidden: 'true' }),
      edit_surveyor_survey_path(survey),
      remote: true,
      class: 'btn btn-warning edit-survey'
    )
  end

  def delete_survey_button(survey)
    content_tag(:button,
      raw(
        content_tag(:span, '', class: 'glyphicon glyphicon-remove', aria: { hidden: 'true' })
      ),
      data: { survey_id: survey.id },
      class: 'btn btn-danger delete-survey'
    )
  end

  def activate_survey_button(survey)
    if survey.surveyable_type == 'Identity'
      content_tag(:button,
        survey.active? ? t(:surveyor)["#{survey.class.name.downcase}s".to_sym][:table][:fields][:disable] : t(:surveyor)["#{survey.class.name.downcase}s".to_sym][:table][:fields][:activate],
        class: survey.active? ? 'btn btn-danger activate-survey' : 'btn btn-success disable-survey',
        title: t(:surveyor)[:forms][:table][:tooltips][:activate],
        data: { toggle: 'tooltip', container: 'body' },
        disabled: 'disabled'
      )
    else
      link_to(
        survey.active? ? t(:surveyor)["#{survey.class.name.downcase}s".to_sym][:table][:fields][:disable] : t(:surveyor)["#{survey.class.name.downcase}s".to_sym][:table][:fields][:activate],
        surveyor_survey_updater_path(survey, klass: 'survey', survey: { active: !survey.active }),
        method: :patch,
        remote: true,
        class: survey.active? ? 'btn btn-danger activate-survey' : 'btn btn-success disable-survey',
      )
    end
  end

  def preview_survey_button(survey)
    link_to(
      content_tag(:span, '', class: 'glyphicon glyphicon-search', aria: { hidden: 'true' }) + t(:surveyor)["#{survey.class.name.downcase}s".to_sym][:table][:fields][:preview],
      surveyor_survey_preview_path(survey),
      remote: true,
      class: 'btn btn-info preview-survey'
    )
  end

  ### Surveys Form ###
  def display_order_options(survey)
    options_from_collection_for_select(
      SystemSurvey.unscoped.where.not(id: survey.id).order(:display_order),
      'display_order',
      'insertion_name',
      survey.display_order + 1
    )+
    content_tag(
      :option,
      t(:constants)[:add_as_last],
      value: (SystemSurvey.maximum(:display_order) || 0)+1,
      selected: survey.display_order == SystemSurvey.maximum(:display_order)
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

  def us_states
    [
      ['Alabama', 'AL'],
      ['Alaska', 'AK'],
      ['Arizona', 'AZ'],
      ['Arkansas', 'AR'],
      ['California', 'CA'],
      ['Colorado', 'CO'],
      ['Connecticut', 'CT'],
      ['Delaware', 'DE'],
      ['District of Columbia', 'DC'],
      ['Florida', 'FL'],
      ['Georgia', 'GA'],
      ['Hawaii', 'HI'],
      ['Idaho', 'ID'],
      ['Illinois', 'IL'],
      ['Indiana', 'IN'],
      ['Iowa', 'IA'],
      ['Kansas', 'KS'],
      ['Kentucky', 'KY'],
      ['Louisiana', 'LA'],
      ['Maine', 'ME'],
      ['Maryland', 'MD'],
      ['Massachusetts', 'MA'],
      ['Michigan', 'MI'],
      ['Minnesota', 'MN'],
      ['Mississippi', 'MS'],
      ['Missouri', 'MO'],
      ['Montana', 'MT'],
      ['Nebraska', 'NE'],
      ['Nevada', 'NV'],
      ['New Hampshire', 'NH'],
      ['New Jersey', 'NJ'],
      ['New Mexico', 'NM'],
      ['New York', 'NY'],
      ['North Carolina', 'NC'],
      ['North Dakota', 'ND'],
      ['Ohio', 'OH'],
      ['Oklahoma', 'OK'],
      ['Oregon', 'OR'],
      ['Pennsylvania', 'PA'],
      ['Puerto Rico', 'PR'],
      ['Rhode Island', 'RI'],
      ['South Carolina', 'SC'],
      ['South Dakota', 'SD'],
      ['Tennessee', 'TN'],
      ['Texas', 'TX'],
      ['Utah', 'UT'],
      ['Vermont', 'VT'],
      ['Virginia', 'VA'],
      ['Washington', 'WA'],
      ['West Virginia', 'WV'],
      ['Wisconsin', 'WI'],
      ['Wyoming', 'WY']
    ]
  end
end
