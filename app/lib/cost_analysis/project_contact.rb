module CostAnalysis
  class ProjectContact
    attr_accessor :role, :name, :email

    def initialize(role, name, email)
      @role = role
      @name = name
      @email = email
    end

    def pi?
      @role == "primary-pi"
    end
  end

end
