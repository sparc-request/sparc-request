class Portal::AssociatedUsersController < Portal::BaseController
  layout nil

  respond_to :html, :json, :js
  before_filter :find_project, :only => [:show, :edit, :new, :create, :update]

  def show
    # TODO: is it right to call to_i here?
    # TODO: id here should be the id of a project role, not an identity
    project_role = @protocol.project_roles.find {|role| role.identity.id == params[:id].to_i}
    @user = project_role.try(:identity)
    render :nothing => true # TODO: looks like there's no view for show
  end

  def edit
    @identity = Identity.find params[:identity_id]
    @protocol_role = ProjectRole.find params[:id]
    @sub_service_request = SubServiceRequest.find params[:sub_service_request_id] if params[:sub_service_request_id]
    respond_to do |format|
      format.js
      format.html
    end
  end

  # TODO: why does edit use identity_id, but new uses user_id?
  def new
    @identity = Identity.find params[:user_id]
    @protocol_role = @protocol.project_roles.build(:identity_id => @identity.id)
    if params[:sub_service_request_id]
      @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
    end
    respond_to do |format|
      format.js
      format.html
    end
  end

  def create
    @protocol_role = @protocol.project_roles.build(params[:project_role])
    @identity = Identity.find @protocol_role.identity_id

    if @protocol_role.validate_one_primary_pi && @protocol_role.validate_uniqueness_within_protocol
      @protocol_role.save
      @identity.update_attributes params[:identity]
      @protocol.emailed_associated_users.each do |project_role|
        UserMailer.authorized_user_changed(project_role.identity, @protocol).deliver
      end
    end

    if params[:sub_service_request_id]
      @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
      @protocol = @sub_service_request.service_request.protocol
      render 'portal/admin/update_associated_users'
    else
      respond_to do |format|
        format.js
        format.html
      end
    end
  end

  def update
    @protocol_role = ProjectRole.find params[:id]    
    @identity = Identity.find @protocol_role.identity_id
    @identity.update_attributes params[:identity]
    @protocol_role.assign_attributes params[:project_role]
    if @protocol_role.validate_one_primary_pi
      @protocol_role.save
      @protocol.emailed_associated_users.each do |project_role|
        UserMailer.authorized_user_changed(project_role.identity, @protocol).deliver
      end
    end

    if params[:sub_service_request_id]
      @protocol = Protocol.find(params[:protocol_id])
      @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
      render 'portal/admin/update_associated_users'
    else
    
      respond_to do |format|
        format.js
        format.html
      end
    end
  end

  def destroy
    @protocol_role = ProjectRole.find params[:id]
    if @protocol_role.is_only_primary_pi?
      render :js => "alert(\"Projects require a PI. Please add a new one before continuing.\")"
    else
      @protocol_role.destroy
      if params[:sub_service_request_id]
        @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
        @protocol = @sub_service_request.service_request.protocol
        render 'portal/admin/update_associated_users'
      else
        respond_to do |format|
          format.js
          format.html
        end
      end
    end
  end

  def search
    term = params[:term].strip
    results = Identity.search(term).map do |i| 
      {
       :label => i.display_name, :value => i.id, :email => i.email, :institution => i.institution, :phone => i.phone, :era_commons_name => i.era_commons_name,
       :college => i.college, :department => i.department, :credentials => i.credentials, :credentials_other => i.credentials_other
      }
    end

    # TODO: this behavior is particularly annoying.  If I backspace over
    # the "No results" in the search box, then I don't type something
    # new quickly enough, it displays "No results" again.  I suppose we
    # should highlight "No results" so that typing something new will
    # automatically overwrite it.
    results = [{:label => 'No Results'}] if results.empty?

    render :json => results.to_json    
  end

private
  def find_project
    @protocol = Protocol.find(params[:protocol_id])
  end
end
