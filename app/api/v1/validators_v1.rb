#Copyright © 2011-2016 MUSC Foundation for Research Development.
#All rights reserved.

module ValidatorsV1

  class RecordPresence < Grape::Validations::SingleOptionValidator

    def validate_param!(attr_name, params)

      klass = @option.classify.constantize

      unless klass.where(id: params[attr_name]).exists?
        raise Grape::Exceptions::Validation, params: [@scope.full_name(attr_name)], message: "is an invalid record"
      end
    end
  end
end
