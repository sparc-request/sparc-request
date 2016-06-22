#Copyright © 2011-2016 MUSC Foundation for Research Development.
#All rights reserved.

module HelpersV1

  def update_service_line_items_count_attribute(params)
    if params.present?
      if params[:line_items_count].to_i > 0
        @object.class.increment_counter :line_items_count, @object.id
      elsif @object.line_items_count > 0
        @object.class.decrement_counter :line_items_count, @object.id
      end
    else
      error!("400 Bad request", 400)
    end
  end

  def presenter(klass, depth)
    submodule = [klass.classify, depth.classify].join

    ['V1', submodule].join('::').constantize
  end

  def find_object(klass, id)
    klass = klass.classify
    error!("#{klass} not found for id=#{id}", 404) unless @object = klass.constantize.where(id: id).first
  end

  def find_objects(klass, params)
    klass = klass.classify

    if params[:ids].any?
      @objects = klass.constantize.where(id: params[:ids])
    elsif params[:query].present?
      # identify invalid parameters (not found in the object)
      invalid_query_parameters = params[:query].select {|key, value| !klass.constantize.column_names.include? key }
      if invalid_query_parameters.present?
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
