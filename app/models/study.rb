# Copyright © 2011-2019 MUSC Foundation for Research Development
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

class Study < Protocol
  validates_presence_of :sponsor_name
  validates_inclusion_of :selected_for_epic, in: [true, false], unless: :bypass_stq_validation

  ##Removed for now, perhaps to be added later
  # validation_group :guarantor_fields, if: :selected_for_epic do
  #   validates :guarantor_contact,
  #             :guarantor_phone,
  #             :guarantor_address,
  #             :guarantor_city,
  #             :guarantor_state,
  #             :guarantor_zip,
  #             :guarantor_county,
  #             :guarantor_country, presence: true
  # end
  # validates :guarantor_fax, numericality: {allow_blank: true, only_integer: true}
  # validates :guarantor_fax, length: { maximum: 10 }
  # validates :guarantor_address, length: { maximum: 500 }
  # validates :guarantor_city, length: { maximum: 40 }
  # validates :guarantor_state, length: { maximum: 2 }
  # validates :guarantor_zip, length: { maximum: 9 }

  validates_format_of :guarantor_email, with: DataTypeValidator::EMAIL_REGEXP, allow_blank: true
  validates_format_of :guarantor_phone, with: DataTypeValidator::PHONE_REGEXP, allow_blank: true

  validates :guarantor_contact, length: { maximum: 192 }

  validate :validate_study_type_answers, unless: :bypass_stq_validation

  def classes
    return [ 'project' ] # for backward-compatibility
  end

  def determine_study_type
    StudyTypeFinder.new(self).study_type
  end

  def determine_study_type_note
    StudyTypeFinder.new(self).determine_study_type_note
  end

  def display_answers
    self.study_type_answers.joins(study_type_question: :study_type_question_group).where(study_type_question_groups: { version: version_type }).order('study_type_questions.order')
  end

  def populate_for_edit
    super
    self.build_research_types_info           unless self.research_types_info
    self.build_human_subjects_info           unless self.human_subjects_info
    self.build_vertebrate_animals_info       unless self.vertebrate_animals_info
    self.build_investigational_products_info unless self.investigational_products_info
    self.build_ip_patents_info               unless self.ip_patents_info
    self.setup_study_types
    self.setup_impact_areas
    self.setup_affiliations
    self.setup_study_type_answers
  end

  def setup_study_types
    position = 1
    obj_names = PermissibleValue.get_key_list('study_type')
    obj_names.each do |obj_name|
      study_type = study_types.detect{|obj| obj.name == obj_name}
      study_type = study_types.build(:name => obj_name, :new => true) unless study_type
      study_type.position = position
      position += 1
    end

    study_types.sort_by(&:position)
  end

  def setup_study_type_answers
    StudyTypeQuestion.find_each do |stq|
      study_type_answer = study_type_answers.detect{|obj| obj.study_type_question_id == stq.id}
      study_type_answer = study_type_answers.build(study_type_question_id: stq.id) unless study_type_answer
    end
  end

  def setup_impact_areas
    position = 1
    obj_names = PermissibleValue.get_hash('impact_area').map{|k,v| k}
    obj_names.each do |obj_name|
      impact_area = impact_areas.detect{|obj| obj.name == obj_name}
      impact_area = impact_areas.build(:name => obj_name, :new => true) unless impact_area
      impact_area.position = position
      position += 1
    end

    impact_areas.sort_by(&:position)
  end

  def setup_affiliations
    position = 1
    obj_names = PermissibleValue.get_key_list('affiliation_type')
    obj_names.each do |obj_name|
      affiliation = affiliations.detect{|obj| obj.name == obj_name}
      affiliation = affiliations.build(:name => obj_name, :new => true) unless affiliation
      affiliation.position = position
      position += 1
    end

    affiliations.sort_by(&:position)
  end

  FRIENDLY_IDS = ["certificate_of_conf", "higher_level_of_privacy", "epic_inbasket", "research_active", "restrict_sending"]

  def validate_study_type_answers
    if Setting.get_value("use_epic") && self.selected_for_epic && StudyTypeQuestionGroup.active.ids.first == self.study_type_question_group_id && self.study_type_answers.any?
      answers = {}
      FRIENDLY_IDS.each do |fid|
        q = StudyTypeQuestion.active.find_by_friendly_id(fid)
        answers[fid] = study_type_answers.find{|x| x.study_type_question_id == q.id}
      end

      if answers['certificate_of_conf'].answer.nil?
        error = 'certificate_of_conf'
      elsif answers['certificate_of_conf'].answer == false
        if answers['higher_level_of_privacy'].answer.nil?
          error = 'higher_level_of_privacy'
        elsif answers['epic_inbasket'].answer.nil?
          error = 'epic_inbasket'
        elsif answers['research_active'].answer.nil?
          error = 'research_active'
        elsif answers['restrict_sending'].answer.nil?
          error = 'restrict_sending'
        end
      end

      if error
        errors.add(:study_type_answers, { error => I18n.t('activerecord.errors.models.protocol.attributes.study_type_answers.blank') })
      end
    end
  end

  def is_epic?
    Setting.get_value("use_epic")
  end
end
