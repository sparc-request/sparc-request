class IdentitiesController < ApplicationController
  def show
    @identity = Identity.find params[:id]
    puts params.inspect
    if params[:project_role_id].blank?
      @project_role = ProjectRole.new
    else
      @project_role = ProjectRole.find params[:project_role_id]
    end
  end

  def add_to_protocol
    @error = nil 
    @error_field = nil
    if params[:project_role][:role].blank?
      @error = "Role can't be blank"
      @error_field = 'role'
    elsif params[:project_role][:role] == 'other' and params[:project_role][:role_other].blank?
      @error = "'Other' role can't be blank"
      @error_field = 'role'
    end

    @protocol_type = session[:protocol_type]

    identity = Identity.find params[:identity][:id]
    identity.update_attributes params[:identity]
    
    # {"identity_id"=>"11968", "first_name"=>"Colin", "last_name"=>"Alstad", "email"=>"alstad@musc.edu", "phone"=>"843-792-5378", "role"=>"pi", "role_other"=>"", 
    # "era_commons_name"=>"adfds", "institution"=>"medical_university_of_south_carolina", "college"=>"college_of_medicine", "department"=>"information_services", 
    # "credentials"=>"md_phd", "credentials_other"=>"", "subspecialty"=>"1130", "action"=>"add_to_protocol", "controller"=>"identities"}
    # insert logic to update identity
   
    # should check if this is an existing project role

    if params[:project_role][:id].blank?
      @project_role = ProjectRole.new params[:project_role]
      @project_role.identity = identity
    else
      @project_role = ProjectRole.find params[:project_role][:id]
      @project_role.update_attributes params[:project_role]
    end
  end
end
