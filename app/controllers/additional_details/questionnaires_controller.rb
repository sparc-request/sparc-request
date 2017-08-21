# Copyright © 2011-2017 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

class AdditionalDetails::QuestionnairesController < ApplicationController
  before_action :authenticate_identity!
  before_action :find_questionable
  before_action :find_questionnaire, only: [:edit, :update, :destroy]
  layout 'additional_details'

  def index
    @questionnaires = @questionable.questionnaires
  end

  def new
    @questionnaire = Questionnaire.new
    @questionnaire.items.build
  end

  def edit
  end

  def create
    @questionnaire = @questionable.questionnaires.new(questionnaire_params)
    
    if @questionnaire.save
      redirect_to additional_details_questionnaires_path(questionable_id: @questionable.id, questionable_type: @questionable.class.base_class.name)
    else
      render :new
    end
  end

  def update
    @questionnaires = @questionable.questionnaires
    if @questionnaire.update(questionnaire_params)
      respond_to do |format|
        format.html{ redirect_to additional_details_questionnaires_path(questionable_id: @questionable.id, questionable_type: @questionable.class.base_class.name) }
        format.js{ render :update }
      end
    else
      render :edit
    end
  end

  def destroy
    @questionnaire.destroy
    redirect_to additional_details_questionnaires_path(questionable_id: @questionable.id, questionable_type: @questionable.class.base_class.name)
  end

  private

  def find_questionnaire
    @questionnaire = Questionnaire.find(params[:id])
  end

  def find_questionable
    @questionable = params[:questionable_type].classify.constantize.find(params[:questionable_id])
  end

  def questionnaire_params
    params.require(:questionnaire).permit!
  end
end
