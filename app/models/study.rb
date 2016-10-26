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

class Study < Protocol
  validates :sponsor_name,                presence: true
  validates :selected_for_epic,           inclusion: [true, false], :if => [:is_epic?]
  validate  :validate_study_type_answers, if: [:selected_for_epic?, "StudyTypeQuestionGroup.active.pluck(:id).first == changed_attributes()['study_type_question_group_id'] || StudyTypeQuestionGroup.active.pluck(:id).first == study_type_question_group_id"]

  def classes
    return [ 'project' ] # for backward-compatibility
  end

  def determine_study_type
    Portal::StudyTypeFinder.new(self).study_type
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
    self.setup_project_roles
  end

  def setup_study_types
    position = 1
    obj_names = StudyType::TYPES.map{|k,v| k}
    obj_names.each do |obj_name|
      study_type = study_types.detect{|obj| obj.name == obj_name}
      study_type = study_types.build(:name => obj_name, :new => true) unless study_type
      study_type.position = position
      position += 1
    end

    study_types.sort_by(&:position)
  end

  def setup_impact_areas
    position = 1
    obj_names = ImpactArea::TYPES.map{|k,v| k}
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
    obj_names = Affiliation::TYPES.map{|k,v| k}
    obj_names.each do |obj_name|
      affiliation = affiliations.detect{|obj| obj.name == obj_name}
      affiliation = affiliations.build(:name => obj_name, :new => true) unless affiliation
      affiliation.position = position
      position += 1
    end

    affiliations.sort_by(&:position)
  end

  def setup_study_type_answers
    StudyTypeQuestion.find_each do |stq|
      study_type_answer = study_type_answers.detect{|obj| obj.study_type_question_id == stq.id}
      study_type_answer = study_type_answers.build(study_type_question_id: stq.id) unless study_type_answer
    end
  end

  def setup_project_roles
    project_roles.build(role: "primary-pi", project_rights: "approve") unless project_roles.primary_pis.any?
  end

  FRIENDLY_IDS = ["certificate_of_conf", "higher_level_of_privacy", "access_study_info", "epic_inbasket", "research_active", "restrict_sending"]

  def validate_study_type_answers
    answers = {}
    FRIENDLY_IDS.each do |fid|
      q = StudyTypeQuestion.active.find_by_friendly_id(fid)
      answers[fid] = study_type_answers.find{|x| x.study_type_question_id == q.id}
    end

    has_errors = false
    begin
      if answers["certificate_of_conf"].answer.nil?
        has_errors = true
      elsif answers["certificate_of_conf"].answer == false
        if (answers["higher_level_of_privacy"].answer.nil?)
          has_errors = true
        elsif (answers["higher_level_of_privacy"].answer == false)
          if answers["epic_inbasket"].answer.nil? || answers["research_active"].answer.nil? || answers["restrict_sending"].answer.nil?
            has_errors = true
          end
        elsif (answers["higher_level_of_privacy"].answer == true)
          if (answers["access_study_info"].answer.nil?)
            has_errors = true
          elsif (answers["access_study_info"].answer == false)
            if answers["epic_inbasket"].answer.nil? || answers["research_active"].answer.nil? || answers["restrict_sending"].answer.nil?
              has_errors = true
            end
          end
        end
      end
    rescue => e
      has_errors = true
    end

    if has_errors
      errors.add(:study_type_answers, "must be selected")
    end
  end

  def is_epic?
    USE_EPIC
  end
end
