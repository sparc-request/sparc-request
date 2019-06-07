# Copyright © 2011-2019 MUSC Foundation for Research Development~
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

class SurveyResponseReport < ReportingModule
  $canned_reports << name unless $canned_reports.include? name # update global variable so that we can populate the list, report won't show in the list without this, unless is necessary so we don't add on refresh in dev. mode

  ################## BEGIN REPORT SETUP #####################

  def self.title
    "Survey Responses"
  end

  # see app/reports/test_report.rb for all options
  def default_options
    {
      "Date Range" => {:field_type => :date_range, :for => "created_at", :from => "2012-03-01".to_date, :to => Date.today},
      SystemSurvey => {:field_type => :select_tag, :custom_name_method => :report_title, :required => true},
      "Include Pending Responses" => { field_type: :check_box_tag, for: "show_pending" }
    }
  end

  # see app/reports/test_report.rb for all options
  def column_attrs
    attrs = {}

    attrs["SRID"] = "respondable.is_a?(ServiceRequest) ? respondable.id : respondable.try(:display_id)"
    attrs["User ID"] = :identity_id
    attrs["User Name"] = "identity.try(:full_name)"
    attrs["Submitted Date"] = "created_at.try(:strftime, \"%D\")"

    if params[:system_survey_id]
      survey = Survey.find(params[:system_survey_id])
      survey.sections.each do |section|
        section.questions.each do |question|
          question.question_responses.each do |qr|
            attrs[ActionView::Base.full_sanitizer.sanitize(question.content)] = "question_responses.any? ? question_responses.where(question_id: #{question.id}).first.try(:report_content) : 'No Response'"
          end
        end
      end
    end

    attrs
  end

  ################## END REPORT SETUP  #####################

  ################## BEGIN QUERY SETUP #####################
  # def table => primary table to query
  # includes, where, uniq, order, and group get passed to AR methods, http://apidock.com/rails/v3.2.13/ActiveRecord/QueryMethods
  # def includes => other tables to include
  # def where => conditions for query
  # def uniq => return distinct records
  # def group => group by this attribute (including table name is always a safe bet, ex. identities.id)
  # def order => order by these attributes (include table name is always a safe bet, ex. identities.id DESC, protocols.title ASC)
  # Primary table to query
  def table
    Response
  end

  # Other tables to include
  def includes
    return :survey
  end

  # Other tables to include
  def joins(args={})
    # If showing pending, do not joins question responses
    return args[:show_pending] ? nil : :question_responses
  end

  # Conditions
  def where args={}
    created_at = (args[:created_at_from] ? args[:created_at_from] : self.default_options["Date Range"][:from]).to_time.strftime("%Y-%m-%d 00:00:00")..(args[:created_at_to] ? args[:created_at_to] : self.default_options["Date Range"][:to]).to_time.strftime("%Y-%m-%d 23:59:59")

    return :responses => {:created_at => created_at, :survey_id => args[:system_survey_id]}
  end

  # Return only uniq records for
  def uniq
    return :responses
  end

  def group
  end

  def order
    "responses.created_at ASC"
  end

  ##################  END QUERY SETUP   #####################

  private

  def create_report(worksheet)
    super

    start_date                = (params[:created_at_from] ? params[:created_at_from] : "2012-03-01".to_date).to_time.strftime("%Y-%m-%d 00:00:00")
    end_date                  = (params[:created_at_to] ? params[:created_at_to] : Date.today).to_time.strftime("%Y-%m-%d 23:59:59")
    # assumes the first question where only one option can be picked is the satisfaction question
    survey                    = Survey.find(params[:system_survey_id])
    questions                 = Question.where(question_type: ['yes_no', 'likert', 'radio_button'], section: Section.where(survey: survey))
    responses                 = QuestionResponse.includes(:response).where(question: questions, responses: { created_at: start_date..end_date }).where.not(content: [nil, ""])
    total_percent_satisfied   = responses.map{ |qr| percent_satisfied(qr.content.downcase) }.sum
    average_percent_satisifed = responses.count == 0 ? 0 : (total_percent_satisfied.to_f / responses.count.to_f).round(2)

    worksheet.add_row([])
    worksheet.add_row(["Overall Satisfaction Rate", "", "#{average_percent_satisifed}%"])
  end

  # assumes all satisfaction question is answered with a likert scale from version 1 of System Satisfaction or SCTR Customer Satisfaction Survey,
  # or Yes or No answer from version 0 of those surveys.
  def percent_satisfied(content)
    if ['yes', 'extremely likely', 'very satisfied'].include?(content)
      100
    elsif ['somewhat likely', 'satisfied'].include?(content)
      80
    elsif ['neutral'].include?(content)
      60
    elsif ['not very likely', 'dissatisfied'].include?(content)
      40
    elsif ['not at all likely', 'very dissatisfied'].include?(content)
      20
    elsif ['no'].include?(content)
      0
    else
      0
    end
  end
end
