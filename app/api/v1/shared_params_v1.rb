#Copyright © 2011-2016 MUSC Foundation for Research Development.
#All rights reserved.

module SharedParamsV1

  extend Grape::API::Helpers

  params :with_depth do
    optional :depth,  type: String,
                      default: 'full',
                      values: ['full', 'shallow', 'full_with_shallow_reflections']

  end
  
  params :custom_query do
    optional :limit, type: Integer
#    optional :order, type: String   
    optional :query, type: Hash
  end
end
