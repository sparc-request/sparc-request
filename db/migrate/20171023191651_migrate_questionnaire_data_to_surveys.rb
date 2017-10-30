class MigrateQuestionnaireDataToSurveys < ActiveRecord::Migration[5.1]
  class Questionnaire < ApplicationRecord
  end
  class Item < ApplicationRecord
  end
  class ItemOption < ApplicationRecord
  end
  class Submission < ApplicationRecord
  end
  class QuestionnaireResponse < ApplicationRecord
  end

  def up
    #########
    # Begin #
    ####################################################################################
    puts "Migrating questionnaire data to survey structure..."
    
    ###################
    # Gather all data #
    ####################################################################################
    puts "  Storing questionnaire data..."
    # Remake Questionnaires as Surveys
    questionnaires = Questionnaire.all.to_a
    # Remake Items as Questions
    items = Item.all.to_a
    # Remake ItemOptions as Options
    item_options = ItemOption.all.to_a
    # Remake Submissions as Responses
    submissions = Submission.all.to_a
    # Remake QuestionnaireResponses as QuestionResponses
    questionnaire_responses = QuestionnaireResponse.all.to_a

    ###################
    # Drop all tables #
    ####################################################################################
    puts "  Dropping tables..."
    drop_table :questionnaire_responses if ActiveRecord::Base.connection.table_exists?('questionnaire_responses')
    drop_table :item_options if ActiveRecord::Base.connection.table_exists?('item_options')
    drop_table :questionnaire_responses if ActiveRecord::Base.connection.table_exists?('questionnaire_responses')
    drop_table :items if ActiveRecord::Base.connection.table_exists?('items')
    drop_table :submissions if ActiveRecord::Base.connection.table_exists?('submissions')    
    drop_table :questionnaires if ActiveRecord::Base.connection.table_exists?('questionnaires')

    ################
    # Rebuild data #
    ####################################################################################
    puts "  Replacing data..."

    questionnaires.each_with_index do |questionnaire, index|
      survey_params = ActionController::Parameters.new({
        title: questionnaire.name,
        description: nil,
        access_code: questionnaire.name.downcase.gsub(" ", "-"),
        display_order: Survey.maximum(:display_order) + 1,
        version: Survey.where(access_code: questionnaire.name.downcase.gsub(" ", "-")).any? ? Survey.where(access_code: questionnaire.name.downcase.gsub(" ", "-")).maximum(:version) + 1 : 0,
        active: questionnaire.active,
        created_at: questionnaire.created_at,
        updated_at: questionnaire.updated_at,
        surveyable_type: questionnaire.questionable_type,
        surveyable_id: questionnaire.questionable_id
      })
      
      new_survey = Form.create(survey_params.permit!)
      
      new_section = Section.create(survey: new_survey)

      items.select{ |i| i.questionnaire_id == questionnaire.id }.each do |item|
        question_params = ActionController::Parameters.new({
          section: new_section,
          is_dependent: false,
          content: item.content,
          question_type: item.item_type,
          description: item.description,
          required: item.required,
          created_at: item.created_at,
          updated_at: item.updated_at,
          depender_id: nil
        })
        new_question = Question.create(question_params.permit!)

        item_options.select{ |io| io.item_id = item.id }.each do |item_option|
          option_params = ActionController::Parameters.new({
            question: new_question,
            content: item_option.content,
            created_at: item_option.created_at,
            updated_at: item_option.updated_at
          })
        end
      end

      submissions.select{ |s| s.questionnaire_id == questionnaire.id }.each do |submission|
        response_params = ActionController::Parameters.new({
          survey: new_survey,
          identity_id: submission.identity_id,
          created_at: submission.created_at,
          updated_at: submission.updated_at,
          respondable_type: 'SubServiceRequest',
          respondable_id: submission.sub_service_request_id
        })
        new_response = Response.create(response_params.permit!)

        questionnaire_responses.select{ |qr| qr.submission_id == submission.id }.each do |questionnaire_response|
          question_response_params = ActionController::Parameters.new({
            question_id: questionnaire_response.item_id,
            response_id: questionnaire_response.submission_id,
            content: questionnaire_response.content,
            required: questionnaire_response.required,
            created_at: questionnaire_response.created_at,
            updated_at: questionnaire_response.updated_at
          })
        end
      end
    end

    puts 'Finished migrating questionnaire data to survey structure...'
  end
end
