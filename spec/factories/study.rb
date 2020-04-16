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

FactoryBot.define do
  factory :study, parent: :protocol, class: 'Study' do
    type {"Study"}

    trait :with_study_type_questions_group do
      after(:create) do |protocol|
        protocol.study_type_question_group = create(:active_study_group_with_questions, protocol_id: protocol.id)
      end
    end

    transient do
      human_subjects            { false }
      vertebrate_animals        { false }
      investigational_products  { false }
      ip_patents                { false }
      with_irb                  { false }
    end

    after(:build) do |protocol, evaluator|
      create(:research_types_info,
        protocol: protocol,
        human_subjects: evaluator.human_subjects,
        vertebrate_animals: evaluator.vertebrate_animals,
        investigational_products: evaluator.investigational_products,
        ip_patents: evaluator.ip_patents
      )

      if evaluator.human_subjects
        hsi = create(:human_subjects_info, protocol: protocol)

        if evaluator.with_irb
          create(:irb_record, human_subjects_info: hsi)
        end
      else
        protocol.build_human_subjects_info(attributes_for(:human_subjects_info))
      end

      if evaluator.vertebrate_animals
        create(:vertebrate_animals_info, protocol: protocol)
      end

      if evaluator.investigational_products
        create(:investigational_products_info, protocol: protocol)
      end

      if evaluator.ip_patents
        create(:ip_patents_info, protocol: protocol)
      end
    end

    factory :study_federally_funded,                    traits: [:funded, :federal]
    factory :study_without_validations,                 traits: [:without_validations]
    factory :unarchived_study_without_validations,      traits: [:without_validations, :unarchived]
    factory :archived_study_without_validations,        traits: [:without_validations, :archived]
    factory :study_with_blank_dates,                    traits: [:pending, :blank_funding_start_dates, :blank_start_and_end_dates]
    factory :study_without_validations_with_questions,  traits: [:without_validations, :with_study_type_questions_group]
  end
end
