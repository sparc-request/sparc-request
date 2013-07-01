class StudiesController < ProtocolsController

  def model_class
    return Study
  end

  def set_protocol_type
    session[:protocol_type] = 'study'
  end
end
