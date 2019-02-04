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

module ArmsHelper

  def arm_name_helper(arm)
    returning_html = content_tag(:span, arm.name)

    if arm.name == 'Screening Phase'
      returning_html += content_tag(:span, '', class: 'glyphicon glyphicon-question-sign screening-info', title: t(:arms)[:screening_tooltip], data: { toggle: 'tooltip' })
    end

    returning_html
  end

  def arms_edit_button(arm, arms_editable)
    content_tag(:button,
      raw(
        content_tag(:span, '', class: 'glyphicon glyphicon-edit', aria: { hidden: 'true' })
      ),
      type: 'button', data: { arm_id: arm.id },
      class: 'btn btn-warning edit-arm-button',
      disabled: !arms_editable
    )
  end

  def arms_delete_button(arm, arms_editable, arm_count)
    content_tag(:button,
      raw(
        content_tag(:span, '', class: 'glyphicon glyphicon-remove', aria: { hidden: 'true' })
      ),
      type: 'button', data: { arm_id: arm.id },
      class: 'btn btn-danger delete-arm-button',
      disabled: !arms_editable || arm_count == 1
    )
  end
end
