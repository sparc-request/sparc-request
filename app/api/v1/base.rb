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
        :identities,
        :project_roles,
        :arms,
        :line_items,
        :line_items_visits,
        :protocols,
        :studies,
        :projects,
        :service_requests,
        :services,
        :service_level_components,
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
            optional :ids, type: Array, default: Array.new
          end

          get do
            find_objects(published_resource_to_s, params[:ids])

            present @objects, with: presenter(published_resource_to_s, params[:depth])
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
    end
  end
end
