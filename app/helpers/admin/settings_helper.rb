# Copyright © 2011-2020 MUSC Foundation for Research Development
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

module Admin::SettingsHelper

  def setting_actions(setting)
    content_tag :div, class: 'd-flex justify-content-center' do
      raw [
        view_setting_button(setting),
        edit_setting_button(setting)
      ].join('')
    end
  end

  def display_setting_value(setting)
    if  setting.value.to_s.length > 45
      link_to 'javascript:void(0)', data: { toggle: 'popover', trigger: 'hover', placement: 'bottom', html: 'true', content: raw(setting[:value]) } do
        truncate(setting[:value], length: 42, separator: ' ')
      end
    else
      setting[:value]
    end
  end

  def format_string(str, max)
    if  str.length > max
      link_to 'javascript:void(0)', data: { toggle: 'popover', trigger: 'hover', placement: 'bottom', html: 'true', content: str } do
        truncate(str, length: max, separator: ' ')
      end
    else
      str
    end
  end

  def view_setting_button(setting)
    link_to icon('fas', 'eye'), admin_setting_path(setting), remote: true, class: 'btn btn-info mr-1', title: t('admin.settings.tooltip.view'), data: { toggle: 'tooltip' }
  end

  def edit_setting_button(setting)
    link_to icon('fas', 'edit'), edit_admin_setting_path(setting), remote: true, class: 'btn btn-warning mr-1', title: t('actions.edit'), data: { toggle: 'tooltip' }
  end
end
