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
    render 'surveyor/surveys/actions_dropdown.html', survey: survey
  end

  def preview_survey
    content_tag(:span, '', class: 'glyphicon glyphicon-search text-info', aria: { hidden: 'true' }) +
    content_tag(:span, t(:actions)[:preview], class: 'text text-info')
  end

  def activate_survey(survey, disabled)
    context_class =
      if disabled
        ''
      elsif survey.active?
        'text-danger'
      else
        'text-success'
      end

    content_tag(:span, '', class: [context_class, survey.active? ? 'glyphicon glyphicon-remove' : 'glyphicon glyphicon-ok'], aria: { hidden: 'true' }) +
    content_tag(:span, (survey.active? ? t(:actions)[:disable] : t(:actions)[:activate]), class: ['text', context_class])
  end

  def copy_survey
    content_tag(:span, '', class: 'glyphicon glyphicon-copy text-primary', aria: { hidden: 'true' }) +
    content_tag(:span, t(:actions)[:copy], class: 'text text-primary')
  end

  def edit_survey(disabled)
    content_tag(:span, '', class: ['glyphicon glyphicon-edit', disabled ? '' : 'text-warning'], aria: { hidden: 'true' }) +
    content_tag(:span, t(:actions)[:edit], class: ['text', disabled ? '' : 'text-warning'])
  end

  def delete_survey(disabled)
    content_tag(:span, '', class: ['glyphicon glyphicon-trash', disabled ? '' : 'text-danger'], aria: { hidden: 'true' }) +
    content_tag(:span, t(:actions)[:delete], class: ['text', disabled ? '' : 'text-danger'])
  end

  ### Surveys Form ###
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
