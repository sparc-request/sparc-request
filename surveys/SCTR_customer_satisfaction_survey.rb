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

survey "SCTR Customer Satisfaction Survey", :default_mandatory => false do
  section "Customer Satisfaction" do

    label "Thank you for working with the South Carolina Clinical and
    Translational Research Institute (SCTR). SCTR is committed to providing quality
    support and requests your feedback on services and tools provided to you.
    The results of your responses will help provide invaluable data to our stakeholders,
    evaluate service provider performance, and guide the development of future resources.
    We would greatly appreciate your participation in a one-question survey.
    Be assured that your answers will be kept confidential."

    question_1 "1) How likely is it that you would recommend this SCTR service to a colleague?", :pick => :one
    answer "Not at all likely", help_text: "1"
    answer "Not very likely", help_text: "2"
    answer "Neutral", help_text: "3"
    answer "Somewhat likely", help_text: "4"
    answer "Extremely likely", help_text: "5"

    question_2 "2) If you would like to provide additional feedback, please use the space below."
    answer :text

    label "Please remember to cite the CTSA grant in any related publication:
    <br>
    <span class='gray-text'>
    \“This publication [or project] was supported by the South Carolina Clinical & Translational Research (SCTR)
    Institute, with an academic home at the Medical University of South Carolina <strong class='dim-gray-text'>NIH - NCATS Grant Number UL1
    TR001450.</strong>\”
    </span>"

  end
end