module FactoryGirl

  # Creates an object of specified class (as a symbol, e.g. :project) and saves without validation.
  def self.create_without_validation class_name, *args
    klass = class_name.to_s.camelize.constantize
    object = klass.new(FactoryGirl.attributes_for(klass.base_class.name.underscore.to_sym))
    object.save(:validate => false)
    
    return object 
  end

end