class ProjectsController < ProtocolsController

  def model_class
    return Project
  end

  def set_protocol_type
    session[:protocol_type] = 'project'
  end
end
