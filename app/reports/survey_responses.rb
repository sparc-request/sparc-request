# Copyright © 2011-2016 MUSC Foundation for Research Development~
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
      "Date Range" => {:field_type => :date_range, :for => "completed_at", :from => "2012-03-01".to_date, :to => Date.today},
      Survey => {:field_type => :select_tag, :custom_name_method => :title, :required => true}
    }
  end

  # see app/reports/test_report.rb for all options
  def column_attrs
    attrs = {}

    attrs["SSR ID"] = "sub_service_request.try(:display_id)"
    attrs["User ID"] = :user_id
    attrs["User Name"] = "identity.try(:full_name)"
    attrs["Submitted Date"] = "completed_at.try(:strftime, \"%D\")"

    if params[:survey_id]
      survey = Survey.find(params[:survey_id])
      survey.sections.each do |section|
        section.questions.each do |question|
          question.answers.each do |answer|
            if answer.response_class == "text"
              attrs[ActionView::Base.full_sanitizer.sanitize(question.text)] = "responses.select{|response| response.question_id == #{question.id}}.first.try(:text_value)"
            else
              attrs[ActionView::Base.full_sanitizer.sanitize(question.text)] = "responses.select{|response| response.question_id == #{question.id}}.first.try(:answer).try(:text)"
            end
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
    ResponseSet
  end

  # Other tables to include
  def includes
    return :survey
  end

  # Other tables to join
  def joins
    return :responses
  end

  # Conditions
  def where args={}
    completed_at = (args[:completed_at_from] ? args[:completed_at_from] : self.default_options["Date Range"][:from]).to_time.strftime("%Y-%m-%d 00:00:00")..(args[:completed_at_to] ? args[:completed_at_to] : self.default_options["Date Range"][:to]).to_time.strftime("%Y-%m-%d 23:59:59")

    return :response_sets => {:completed_at => completed_at, :survey_id => args[:survey_id]}
  end

  # Return only uniq records for
  def uniq
    return :response_sets
  end

  def group
  end

  def order
    "response_sets.completed_at ASC"
  end

  ##################  END QUERY SETUP   #####################

  private

  def create_report(worksheet)
    super

    # only add satisfaction rate to the bottom of reports for the system satisfaction survey
    if params["survey_id"] == Survey.find_by(access_code: "system-satisfaction-survey").id.to_s
      record_answers = records.map { |record| record.responses.where(question_id: 1).first.try(:answer).try(:text) }.compact
      yes_answers = record_answers.select { |answer| answer == "Yes" }
      percent_satisifed = yes_answers.length.to_f / record_answers.length * 100

      worksheet.add_row([])
      worksheet.add_row(["Overall Satisfaction Rate", "", sprintf("%.2f%%", percent_satisifed)])
    end
  end
end
