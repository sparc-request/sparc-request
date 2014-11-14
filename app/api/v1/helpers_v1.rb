module HelpersV1

  def presenter(klass, depth)
    submodule = [klass.classify, depth.classify].join

    ['V1', submodule].join('::').constantize
  end

  def find_object(klass, id)
    klass = klass.classify

    error!("#{klass} not found", 404) unless @object = klass.constantize.find(id)
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
