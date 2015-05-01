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

    error!("#{klass} not found", 404) unless @object = klass.constantize.where(id: id).first
  end

  def find_objects(klass, ids)
    klass = klass.classify

    if ids.any?
      @objects = klass.constantize.where(id: ids)
    else
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
