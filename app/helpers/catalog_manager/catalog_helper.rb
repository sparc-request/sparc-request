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

module CatalogManager::CatalogHelper

  def folder_glyphicon()
    content_tag(:span, '', class: 'catalog-glyphicon glyphicon glyphicon-folder-close')
  end

  def file_glyphicon()
    content_tag(:span, '', class: 'catalog-glyphicon glyphicon glyphicon-file')
  end

  def plus_glyphicon()
    content_tag(:span, '', class: 'catalog-glyphicon glyphicon glyphicon-plus')
  end

  def accordion_link_text(org, disabled=false)
    if org.is_a?(Service)
      css_class = org.is_available ? 'text-service' : 'text-service unavailable-org'
      returning_html = content_tag(:span, org.name, class: css_class)
    else
      css_class = org.is_available ? "text-#{org.type.downcase}" : "text-#{org.type.downcase} unavailable-org"
      returning_html = content_tag(:span, org.name, class: css_class)
    end

    if disabled
      returning_html.insert(0, content_tag(:span, '', class: 'catalog-glyphicon glyphicon glyphicon-ban-circle'))
    end

    returning_html
  end

  def create_new_text(org_key)
    content_tag(:span, t(:catalog_manager)[:catalog][:new][org_key], class: "text-#{org_key}")
  end

  def disabled_parent organization
    if (orgs = organization.parents.insert(0, organization).select{|org| !org.is_available}).any?
      I18n.t('catalog_manager.organization_form.disabled_at', disabled_parent: orgs.last.name)
    end
  end
end
