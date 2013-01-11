def json_factory(object, klass)
  ViewModel.class_eval(klass).from_entity(object)
end

def simple_json_factory(object, klass)
  ViewModel.from_simple(object, klass)
end

