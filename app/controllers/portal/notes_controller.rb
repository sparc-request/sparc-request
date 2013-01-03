class Portal::NotesController < Portal::BaseController
  respond_to :html, :json

  def create
    @note = Note.create(params[:note])
    @sub_service_request = @note.sub_service_request

    respond_to do |format|
      format.js
      format.html
    end
  end

  def destroy
  end
  
end