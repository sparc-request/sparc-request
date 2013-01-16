class Portal::ProtocolsController < Portal::BaseController
  respond_to :html, :json

  def index
    @protocols = @user.protocols.sort_by { |pr| (pr.id || '0000') + pr.id }.reverse
    @notifications = @user.user_notifications
    #@projects = Project.remove_projects_due_to_permission(@projects, @user)

    # params[:default_project] = '0f6a4d750fd369ff4ae409373000ba69'
    if params[:default_protocol]
      protocol = @protocols.select{ |p| p.id == params[:default_protocol].to_i}[0]
      @protocols.delete(protocol)
      @protocols.insert(0, protocol)
    end

    respond_to do |format|
      format.js
      format.html
    end
  end

  def show
    @protocol = Protocol.find(params[:id])
    @protocol_role = @protocol.project_roles.find_by_identity_id(@user.id)
    #@project.project_associated_users
    #@project.project_service_requests

    respond_to do |format|
      format.js
      format.html
    end
  end

  def edit
    @protocol = Protocol.find(params[:id])
    @protocol.populate_for_edit if @protocol.type == "Study"
    respond_to do |format|
      format.html
    end
  end

  def update
    @protocol = Protocol.find(params[:id])
    attrs = params[@protocol.type.downcase.to_sym]
    if @protocol.update_attributes attrs
      flash[:notice] = "Study updated"
      redirect_to portal_root_path(:default_protocol => @protocol)
    else
      @protocol.populate_for_edit if @protocol.type == "Study"
      render :action => 'edit'
    end
  end

  def add_associated_user
    @protocol = Protocol.find(params[:id])

    @project_role = @protocol.project_roles.build(:identity_id => @user.id)
    respond_to do |format|
      format.js
      format.html
    end
  end


  private
  # TODO: Move this somewhere else. Short on time, though. - nb
  def merge_attributes(protocol, data)
    protocol.instance_values.each do |k, v|
      data.merge!({k => v}) unless data.include?(k)
    end
  end

  def fix_funding(data)
    if data["funding_status"] == "pending_funding" && data["_type"] != "project"
      data.delete("funding_source")
      data.delete("funding_source_other")
      data.delete("funding_start_date")
    elsif data["funding_status"] == "funded"
      data.delete("potential_funding_source")
      data.delete("potential_funding_source_other")
      data.delete("potential_funding_start_date")
    end
  end
end
