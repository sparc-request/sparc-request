# Copyright © 2011-2022 MUSC Foundation for Research Development
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

module Admin::PermissibleValuesHelper

  def pv_actions(permissible_value)
    content_tag :div, class: 'd-flex justify-content-center' do
      raw [
        view_pv_button(permissible_value),
        edit_pv_button(permissible_value)
      ].join('')
    end
  end

  def view_pv_button(pv)
    link_to icon('fas', 'eye'), admin_permissible_value_path(pv), remote: true, class: 'btn btn-info mr-1', title: t('admin.permissible_values.tooltip.view'), data: { toggle: 'tooltip' }
  end

  def edit_pv_button(pv)
    if pv.default || pv.reserved
      content_tag :div, icon('fas', 'edit'), class: 'btn btn-light', title: t('admin.permissible_values.action.edit_disabled'), data: { toggle: 'tooltip' }    
    else
      link_to icon('fas', 'edit'), edit_admin_permissible_value_path(pv), remote: true, class: 'btn btn-warning mr-1', title: t('actions.edit'), data: { toggle: 'tooltip' }
    end
  end
end