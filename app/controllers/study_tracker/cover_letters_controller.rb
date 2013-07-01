class StudyTracker::CoverLettersController < StudyTracker::BaseController
  before_filter :load_sub_service_request

  def new
    @cover_letter = @sub_service_request.cover_letters.build

    @srid = "#{@sub_service_request.service_request.protocol.id}-#{@sub_service_request.ssr_id}"
    @short_title = @sub_service_request.service_request.protocol.short_title
  end

  def create
    sanitizer = CoverLetterSanitizer.new
    params[:cover_letter][:content] = sanitizer.sanitize(params[:cover_letter][:content])

    if @cover_letter = @sub_service_request.cover_letters.create(params[:cover_letter])
      redirect_to [:study_tracker, @sub_service_request]
    else
      render :new
    end
  end

  def show
    @cover_letter = CoverLetter.find(params[:id])
  end

  private

  def load_sub_service_request
        @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
  end
end