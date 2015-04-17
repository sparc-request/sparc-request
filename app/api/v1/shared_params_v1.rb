module SharedParamsV1

  extend Grape::API::Helpers

  params :with_depth do
    optional :depth,  type: String,
                      default: 'full',
                      values: ['full', 'shallow', 'full_with_shallow_reflections']

  end
end
