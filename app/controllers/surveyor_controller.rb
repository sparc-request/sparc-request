# encoding: UTF-8
require 'csv'
module SurveyorControllerCustomMethods
  def self.included(base)
    base.send :before_filter, :set_current_user
    # base.send :before_filter, :authenticate_identity! # SPARC Request Authentication
    # base.send :before_filter, :require_user   # AuthLogic
    # base.send :before_filter, :login_required  # Restful Authentication
    # base.send :layout, 'surveyor_custom'
  end
  
  def set_current_user
    @current_user = current_user
  end

  # Actions
  def new
    super
    # @title = "You can take these surveys"
  end
  def create
    super
  end
  def show
    super
  end
  def edit
    super
  end
  def update
    super
  end

  def export
    survey_version = params["survey_version"]
    access_code = params["survey_code"]
    pretty_print = params["pretty_print"]

    params_string = "code #{access_code}"

    surveys = Survey.where(:access_code => access_code).order("survey_version ASC")
    if survey_version.blank?
      survey = surveys.last
    else
      params_string += " and survey_version #{survey_version}"
      survey = surveys.where(:survey_version => survey_version).first
    end

    raise "No Survey found with #{params_string}" unless survey
    dir = Rails.root + '/tmp'
    FileUtils.mkpath(dir) # Create all non-existent directories
    full_path = File.join(dir,"#{survey.access_code}_v#{survey.survey_version}_#{Time.now.to_i}.csv")
    File.open(full_path, 'w') do |f|
      if pretty_print
        f.write(survey.response_sets.first.survey.sections.map{|section| section.questions.order(:display_order).map(&:text)}.flatten.to_csv) #header
        question_ids = survey.sections.map{|section| section.questions.order(&:display_order).map(&:id)}.flatten
        survey.response_sets.each do |response_set|
          next if response_set.responses.empty?
          f.write(question_ids.map{|q| response_set.responses.find_by_question_id(q).try(:to_formatted_s)}.to_csv)
        end
      else
        survey.response_sets.each_with_index{|r,i| f.write(r.to_csv(true, i == 0)) } # print access code every time, print_header first time
      end
    end

    send_file full_path    
  end

  # Paths
  def surveyor_index
    # most of the above actions redirect to this method
    super # surveyor.available_surveys_path
  end
  def surveyor_finish
    # the update action redirects to this method if given params[:finish]
    if not params['redirect_to'].blank?
      SurveyNotification.system_satisfaction_survey(@response_set).deliver
      params['redirect_to']
    else
      super # surveyor.available_surveys_path
    end
  end
end
class SurveyorController < ApplicationController
  include Surveyor::SurveyorControllerMethods
  include SurveyorControllerCustomMethods
end
