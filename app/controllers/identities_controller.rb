class IdentitiesController < ApplicationController
  def show
    @identity = Identity.find params[:id]
  end

  def add_to_protocol
    @error = nil 
    @error_field = nil
    if params[:role].blank?
      @error = "Role can't be blank"
      @error_field = 'role'
    elsif params[:role] == 'other' and params[:role_other].blank?
      @error = "'Other' role can't be blank"
      @error_field = 'role'
    end

    @protocol_type = session[:protocol_type]

    identity = Identity.find params[:identity_id]
    
    puts "#"*50
    puts params.inspect
    puts "#"*50
    # insert logic to update identity
   
    # should check if this is an existing project role
    @project_role = ProjectRole.new :identity_id => identity.id, :role => (params[:role] == 'other' ? params[:role_other] : params[:role])
  end
end
