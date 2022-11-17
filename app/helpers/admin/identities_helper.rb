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

module Admin::IdentitiesHelper
  def identity_actions(identity)
    content_tag :div, class: 'd-flex justify-content-center' do
      raw [
        view_identity_button(identity),
        edit_identity_button(identity)
      ].join('')
    end
  end

  def view_identity_button(identity)
    link_to icon('fas', 'eye'), admin_identity_path(identity), remote: true, class: 'btn btn-info mr-1', title: t('admin.identities.tooltips.view'), data: { toggle: 'tooltip' }
  end

  def edit_identity_button(identity)
    link_to icon('fas', 'edit'), edit_admin_identity_path(identity), remote: true, class: 'btn btn-warning mr-1', title: t('admin.identities.tooltips.edit'), data: { toggle: 'tooltip' }
  end

  def display_name(identity)
    identity.last_name_first + (identity.approved ? "" : inactive_tag)
  end
end