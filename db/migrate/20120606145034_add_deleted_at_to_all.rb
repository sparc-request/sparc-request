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

class AddDeletedAtToAll < ActiveRecord::Migration
  def change
    add_column :affiliations                   , :deleted_at  , :datetime
    add_column :approvals                      , :deleted_at  , :datetime
    add_column :catalog_managers               , :deleted_at  , :datetime
    add_column :charges                        , :deleted_at  , :datetime
    add_column :excluded_funding_sources       , :deleted_at  , :datetime
    add_column :fulfillments                   , :deleted_at  , :datetime
    add_column :human_subjects_info            , :deleted_at  , :datetime
    add_column :identities                     , :deleted_at  , :datetime
    add_column :impact_areas                   , :deleted_at  , :datetime
    add_column :investigational_products_info  , :deleted_at  , :datetime
    add_column :ip_patents_info                , :deleted_at  , :datetime
    add_column :line_items                     , :deleted_at  , :datetime
    add_column :organizations                  , :deleted_at  , :datetime
    add_column :past_statuses                  , :deleted_at  , :datetime
    add_column :pricing_maps                   , :deleted_at  , :datetime
    add_column :project_roles                  , :deleted_at  , :datetime
    add_column :protocols                      , :deleted_at  , :datetime
    add_column :research_types_info            , :deleted_at  , :datetime
    add_column :service_relations              , :deleted_at  , :datetime
    add_column :service_requests               , :deleted_at  , :datetime
    add_column :services                       , :deleted_at  , :datetime
    add_column :study_types                    , :deleted_at  , :datetime
    add_column :sub_service_requests           , :deleted_at  , :datetime
    add_column :submission_emails              , :deleted_at  , :datetime
    add_column :subsidies                      , :deleted_at  , :datetime
    add_column :subsidy_maps                   , :deleted_at  , :datetime
    add_column :super_users                    , :deleted_at  , :datetime
    add_column :tokens                         , :deleted_at  , :datetime
    add_column :vertebrate_animals_info        , :deleted_at  , :datetime
    add_column :visits                         , :deleted_at  , :datetime
  end
end
