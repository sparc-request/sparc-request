#Copyright © 2011-2016 MUSC Foundation for Research Development.
#All rights reserved.

module SPARCCWF

  module V1

    require_relative 'entities.rb'

    class APIv1 < Grape::API

      require_relative 'validators_v1.rb'
      require_relative 'shared_params_v1.rb'
      require_relative 'helpers_v1.rb'

      version 'v1', using: :path
      format :json

      http_basic do |username, password|

        begin
          username == REMOTE_SERVICE_NOTIFIER_USERNAME &&
            password == REMOTE_SERVICE_NOTIFIER_PASSWORD
        rescue
          false
        end
      end

      helpers SharedParamsV1
      helpers HelpersV1

      published_resources = [
        :organizations,
        :clinical_providers,
        :identities,
        :project_roles,
        :arms,
        :human_subjects_infos,
        :line_items,
        :line_items_visits,
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
