# Copyright © 2011-2016 MUSC Foundation for Research Development
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

class Surveyor::SurveysController < ApplicationController
  respond_to :html, :js, :json

  before_action :authenticate_identity!
  before_action :authorize_site_admin

  def index
    respond_to do |format|
      format.html
      format.json {
        @surveys = Survey.all
      }
    end
  end

  def show
    @survey = Survey.eager_load(sections: { questions: :options }).find(params[:id])

    respond_to do |format|
      format.js
    end
  end

  def create
    @survey = Survey.create(
                title: "Untitled Survey",
                access_code: "untitled-survey",
                version: (Survey.where(access_code: "untitled-survey").order(:version).last.try(:version) || 0) + 1,
                active: true,
                display_order: (Survey.all.order(:display_order).last.try(:display_order) || 0) + 1
              )

    redirect_to surveyor_survey_path(@survey), format: :js
  end

  def destroy
    Survey.find(params[:id]).destroy

    respond_to do |format|
      format.js
    end
  end

  def preview
    @survey = Survey.find(params[:survey_id])
    @response = @survey.responses.new()
    @response.question_responses.build

    respond_to do |format|
      format.html
      format.js
    end
  end

  def update_dependents_list
    @survey     = Survey.find(params[:survey_id])
    @questions  = @survey.questions.eager_load(section: :survey)

    respond_to do |format|
      format.js
    end
  end
end
