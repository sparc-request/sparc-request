# Copyright © 2011-2022 MUSC Foundation for Research Development~
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

require 'doorkeeper/grape/helpers'

module SPARCCWF
  module V1
    require_relative 'entities.rb'

    class APIv1 < Grape::API
      include Grape::Extensions::Hashie::Mash::ParamBuilder
      use ActionDispatch::RemoteIp

      require_relative 'validators_v1.rb'
      require_relative 'shared_params_v1.rb'
      require_relative 'helpers_v1.rb'

      helpers Doorkeeper::Grape::Helpers
      helpers SharedParamsV1
      helpers HelpersV1

      version 'v1', using: :path
      format :json

      before do
        doorkeeper_authorize!
      end

      published_resources = [
        :organizations,
        :clinical_providers,
        :identities,
        :project_roles,
        :arms,
        :human_subjects_infos,
        :irb_records,
        :line_items,
        :line_items_visits,
        :organizations,
        :protocols,
        :studies,
        :projects,
        :service_requests,
        :services,
        :sub_service_requests,
        :visit_groups,
        :visits
      ]

      published_resources.each do |published_resource|

        resource published_resource do

          published_resource_to_s = published_resource.to_s

          desc 'GET /v1/:resources.json'

          params do
            use :with_depth
            use :custom_query
            optional :ids, type: Array, default: Array.new
          end

          get do
            Setting.preload_values

            find_objects(published_resource_to_s, params)
            if @objects
              present @objects, with: presenter(published_resource_to_s, params[:depth])
            # for queries with where and a limit of 1
            elsif @object
              present @object, with: presenter(published_resource_to_s, params[:depth])
            end
          end

          route_param :id do

            desc 'GET /v1/:resource/:id.json'

            params do
              use :with_depth
            end

            get do
              Setting.preload_values

              find_object(published_resource_to_s, params[:id])

              present @object, with: presenter(published_resource_to_s, params[:depth])
            end
          end
        end
      end

      resource :services do

        route_param :id do

          put do
            find_object('service', params[:id])

            update_service_line_items_count_attribute params[:service]

            :ok
          end
        end
      end
    end
  end
end

module ResearchBilling
  module V1
    class APIv1 < Grape::API
      include Grape::Extensions::Hashie::Mash::ParamBuilder
      use ActionDispatch::RemoteIp
      helpers Doorkeeper::Grape::Helpers
      
      before do
        #doorkeeper_authorize!
      end

      get :procedure_check do
        protocol_id = params['protocolNo'].sub('STUDY', '')
        procedure_cpt = params['procedureid']
        date_of_service = Date.strptime(params['dateofservice']).to_time

        protocols = Protocol.where(id: protocol_id)
        # should only have 1 match
        protocol = protocols.first
        services = protocol.services.where(cpt_code: procedure_cpt)

        if protocol.present? && services.present?
          service_ids = services.map(&:id)

          # check if any visit group has the date_of_service within the start/end date range and procedure_cpt within one of it's services
          # matches = [[date_matching_tolerence, chargeable_procedure]]
          matches = []
         
          protocol.visit_groups.each_with_index do |visit_group,index|
            if visit_group.could_occur.include?(date_of_service) && (visit_group.line_items_visits.map{|liv| liv.line_item.service_id } & service_ids).present?
              matches[index] = [true] # date_matching_tolerence

              line_items_visits = visit_group.line_items_visits.select{|liv| service_ids.include?(liv.line_item.service_id)}
              visits = visit_group.visits.where(line_items_visit_id: line_items_visits)
              matches[index] << visits.any?{|v| v.research_billing_qty > 0}
            end
          end
          
          { matches: matches } 
        else 
          { datematchingtolerence: false, chargeableprocedure: false }
        end
      end
    end
  end
end
