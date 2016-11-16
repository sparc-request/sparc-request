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
class StudyTypeController < ApplicationController
  before_filter :clean_up_params,               only: [:determine_study_type_note]
  def determine_study_type_note
    study_type = determine_study_type(@study_type_answers)
    @note = determine_note(study_type)
  end

  def determine_study_type(study_type_answers)
    STUDY_TYPE_ANSWERS_VERSION_3.each do |k, v|
      if v == study_type_answers
        @study_type = k
        break
      end
    end
    @study_type
  end

  def determine_note(study_type)
    STUDY_TYPE_NOTES.each do |k, v|
      if k == study_type
        @note = v
        break
      end
    end
    @note
  end

  def clean_up_params
    params.delete('controller')
    params.delete('action')
    @study_type_answers = []
    if params['ans1'] == 'true'
      params.values.each do |value|
        @study_type_answers = [true, nil, nil, nil, nil]
      end
    else
      params.values.each do |value|
        @study_type_answers << value.to_s.eql?('true') ? true : false
      end
    end
    @study_type_answers 
  end
end
