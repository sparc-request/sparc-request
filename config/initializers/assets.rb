# Copyright © 2011-2019 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

SparcRails::Application.config.assets.paths.unshift "#{Rails.root}/themes/assets/stylesheets"
SparcRails::Application.config.assets.paths.unshift "#{Rails.root}/themes/assets/images"
SparcRails::Application.config.assets.paths.unshift "#{Rails.root}/themes/assets/javascripts"
Rails.application.config.assets.paths << Rails.root.join('node_modules')
Rails.application.config.assets.precompile += %w( admin/application.css )
Rails.application.config.assets.precompile += %w( admin/application.js )
Rails.application.config.assets.precompile += %w( admin/bootstrap-accessibility.min.js )
Rails.application.config.assets.precompile += %w( associated_users_table.css )
Rails.application.config.assets.precompile += %w( catalog_manager/application.css )
Rails.application.config.assets.precompile += %w( catalog_manager/application.js )
Rails.application.config.assets.precompile += %w( catalog.js )
Rails.application.config.assets.precompile += %w( confirmation.js )
Rails.application.config.assets.precompile += %w( custom.css )
Rails.application.config.assets.precompile += %w( dashboard/application.js )
Rails.application.config.assets.precompile += %w( document_management.js )
Rails.application.config.assets.precompile += %w( filterrific/filterrific-spinner.gif )
Rails.application.config.assets.precompile += %w( forms.js )
Rails.application.config.assets.precompile += %w( ie.css )
Rails.application.config.assets.precompile += %w( ie7_warning.js )
Rails.application.config.assets.precompile += %w( ie8_plus.css )
Rails.application.config.assets.precompile += %w( login.js )
Rails.application.config.assets.precompile += %w( proper/notification_email.css )
Rails.application.config.assets.precompile += %w( protocol_form.css )
Rails.application.config.assets.precompile += %w( protocol_form.js )
Rails.application.config.assets.precompile += %w( protocol.js )
Rails.application.config.assets.precompile += %w( push_to_epic.js )
Rails.application.config.assets.precompile += %w( reporting.js )
Rails.application.config.assets.precompile += %w( review.js )
Rails.application.config.assets.precompile += %w( right_navigation.js )
Rails.application.config.assets.precompile += %w( service_calendar.js )
Rails.application.config.assets.precompile += %w( service_calendar_logic.js )
Rails.application.config.assets.precompile += %w( service_details.js )
Rails.application.config.assets.precompile += %w( service_subsidy.js )
Rails.application.config.assets.precompile += %w( surveyor/responses.js )
Rails.application.config.assets.precompile += %w( surveyor/responses.css )
Rails.application.config.assets.precompile += %w( surveyor/surveys.js )
Rails.application.config.assets.precompile += %w( surveyor/responses.css )
Rails.application.config.assets.precompile += %w( system_satisfaction.css )
Rails.application.config.assets.precompile += %w( system_satisfaction.js )
Rails.application.config.assets.precompile += %w( view_details.css )
Rails.application.config.assets.precompile += %w( funding/documents.js )
