class IdentitiesController < ApplicationController
  def show
    @identity = Identity.find params[:id]
  end

  def add_to_protocol
    @error = nil 
    if params[:role].blank?
      @error = 'Please assign a role.'
    elsif params[:role] == 'other' and params[:role_other].blank?
      @error = 'Please describe the "Other" role.'
    end

    identity = Identity.find params[:identity_id]
    
    puts "#"*50
    puts params.inspect
    puts "#"*50
    # insert logic to update identity
    
    @project_role = ProjectRole.new :identity_id => identity.id, :role => (params[:role] == 'other' ? params[:role_other] : params[:role])
  end
end
