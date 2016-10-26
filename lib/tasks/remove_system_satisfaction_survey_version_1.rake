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

namespace :data do
  desc 'Remove System Satisfaction Survey V1 and its dependencies' 
  task :remove_sys_sat_survey_v1 => :environment do

    @survey_count = 0
    @associated_survey_count = 0
    @survey_translation_count = 0
    @response_set_count = 0
    @survey_section_count = 0
    @question_count = 0
    @response_count = 0

    @sys_sat_survey_v0_id = nil
    @sys_sat_survey_v1_id = nil

    Survey.where(title: "System Satisfaction survey").each do |survey|
      if survey.survey_version == 0
        @sys_sat_survey_v0_id = survey.id
      elsif survey.survey_version == 1
        @sys_sat_survey_v1_id = survey.id
      end
    end


    #Make sure that we have both System Satisfaction Survey Versions
    if !@sys_sat_survey_v0_id.nil? && !@sys_sat_survey_v1_id.nil?
      #Reassign the Associated Surveys (These are individual)
      fix_associated_surveys

      #Destroy the Survey Translations (These are duplicated)
      fix_survey_translations
      
      #Reassign the Response Sets (These are individual)
      fix_response_sets

      #Reassign the Responses (These are individual)
      fix_responses

      #Destroy the Survey
      #Destroy the Survey Sections associated with the Survey
      #Destroy the Questions associated with the Survey Sections
      Survey.destroy(@sys_sat_survey_v1_id)
      @survey_count+=1

      puts "Destroyed #{@survey_count} Survey(s)."
      puts "Updated #{@associated_survey_count} Associated Survey(s)."
      puts "Destroyed #{@question_count} Question(s)."
      puts "Updated #{@response_count} Response(s)."
      puts "Updated #{@response_set_count} Response Set(s)"
      puts "Destroyed #{@survey_section_count} Survey Section(s)."
      puts "Destroyed #{@survey_translation_count} Survey Translation(s)."
    else
      puts "It appears that you do not currently have System Satisfaction Survey Versions 0 and 1."
    end
  end

  def fix_associated_surveys
    AssociatedSurvey.where(survey_id: @sys_sat_survey_v1_id).each do |as|
      @associated_survey_count+=1
      as.update_attributes(survey_id: @sys_sat_survey_v0_id)
    end
  end

  def fix_survey_translations
    SurveyTranslation.where(survey_id: @sys_sat_survey_v1_id).each do |st|
      @survey_translation_count+=1
      SurveyTranslation.destroy(st.id)
    end
  end

  def fix_response_sets
    ResponseSet.where(survey_id: @sys_sat_survey_v1_id).each do |rs|
      @response_set_count+=1
      rs.update_attributes(survey_id: @sys_sat_survey_v0_id)
    end
  end

  def fix_responses
    SurveySection.where(survey_id: @sys_sat_survey_v1_id).each do |ss|
      @survey_section_count+=1
      Question.where(survey_section_id: ss.id).each do |q|
        @question_count+=1
        Response.where(question_id: q.id).each do |r|
          @response_count+=1
          r.update_attributes(question_id: r.question_id - 3)
        end
      end
    end
  end
end
