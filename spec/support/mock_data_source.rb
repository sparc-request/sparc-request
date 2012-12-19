class MockDataSource
  class Undefined; end

  attr_reader :result, :results

  def results
    @results
  end

  def initialize(entities)
    @entities = entities
    @result = Undefined
    @results = []
  end

  def get(entity_type, interface=:simple)
    if block_given?
      return yield @entities[entity_type]
    end

    @entities[entity_type]
  end

  def put(entity, entity_type)
    @results << entity
    @result = entity
  end
end
