# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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
    render :layout => false # Used by PDFkit to avoid rendering the layout
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