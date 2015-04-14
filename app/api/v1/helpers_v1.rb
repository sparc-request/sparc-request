module HelpersV1

  def presenter(klass, depth)
    submodule = [klass.classify, depth.classify].join

    ['V1', submodule].join('::').constantize
  end

  def find_object(klass, id)
    klass = klass.classify

    error!("#{klass} not found", 404) unless @object = klass.constantize.find(id)
  end

  def find_objects(klass, params)
    klass = klass.classify

    if params[:ids].any?
      @objects = klass.constantize.where(id: params[:ids])
    elsif params[:query] && params[:query].length > 0
      # identify invalid parameters (not found in the object)
      invalid_query_parameters = params[:query].select {|key, value| !klass.constantize.column_names.include? key }
      if invalid_query_parameters && invalid_query_parameters.length > 0
        error!("#{klass} query #{params[:query]} has the following invalid parameters: #{invalid_query_parameters.keys}", 400)
      elsif params[:limit] == 1 # return only one object, the first that meets the query criteria
        error!("#{klass} not found for query #{params[:query]}", 404) unless @object = klass.constantize.where(params[:query]).first
      else # return all objects that meet the query criteria
        @objects = klass.constantize.where(params[:query]).limit(params[:limit]) # a nil limit is ignored by ActiveRecord
      end
    else # only apply params[:limit] if params[:query] exists
      @objects = klass.constantize.all
    end
  end

  def current_user
    @current_user ||= User.authorize!(env)
  end

  def authenticate!
    error!('401 Unauthorized', 401) unless current_user
  end
end
