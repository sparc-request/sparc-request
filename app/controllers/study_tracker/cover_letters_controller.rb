class StudyTracker::CoverLettersController < StudyTracker::BaseController
  before_filter :load_sub_service_request
  before_filter :sanitize_content, only: [:create, :update]

  def new
    @cover_letter = @sub_service_request.cover_letters.build

    @srid = "#{@sub_service_request.service_request.protocol.id}-#{@sub_service_request.ssr_id}"
    @short_title = @sub_service_request.service_request.protocol.short_title
  end

  def create
    if @cover_letter = @sub_service_request.cover_letters.create(params[:cover_letter])
      redirect_to [:study_tracker, @sub_service_request]
    else
      render :new
    end
  end

  def show
    @cover_letter = CoverLetter.find(params[:id])
  end

  def edit
    @cover_letter = CoverLetter.find(params[:id])
  end

  def update
    @cover_letter = CoverLetter.find(params[:id])
    if @cover_letter.update_attributes(params[:cover_letter])
      redirect_to [:study_tracker, @sub_service_request]
    else
      render :edit
    end
  end

  private

  def load_sub_service_request
    @sub_service_request = SubServiceRequest.find(params[:sub_service_request_id])
  end

  def sanitize_content
    params[:cover_letter][:content] = CoverLetterSanitizer.new.sanitize(params[:cover_letter][:content].to_s)
  end
end