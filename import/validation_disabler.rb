module ValidationDisabler
  def self.included(base)
    base.class_eval do
      extend ClassMethods
      alias_method_chain :valid?, :disable_check
    end
  end
  
  def valid_with_disable_check?(*args)
    if self.class.validation_disabled?
      true
    else
      valid_without_disable_check?(*args)
    end
  end
  
  module ClassMethods
    def disable_validation!
      @@disable_validation = true
    end
    
    def enable_validation!
      @@disable_validation = false
    end
    
    def validation_disabled?
      @@disable_validation ||= false
    end
  end
end

class ActiveRecord::Base
  include ValidationDisabler
end
