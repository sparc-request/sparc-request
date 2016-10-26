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

# encoding: UTF-8
class CreateAnswers < ActiveRecord::Migration
  def self.up
    create_table :answers do |t|
      # Context
      t.integer :question_id

      # Content
      t.text :text
      t.text :short_text #Used for presenting responses to experts (ie non-survey takers). Just a shorted version of the string
      t.text :help_text
      t.integer :weight # Used to assign a weight to an answer object (used for computing surveys that have numerical results) (I added this to support the Urology questionnaire -BLC)
      t.string :response_class # What kind of additional data does this answer accept?

      # Reference
      t.string :reference_identifier # from paper
      t.string :data_export_identifier # data export
      t.string :common_namespace # maping to a common vocab
      t.string :common_identifier # maping to a common vocab

      # Display
      t.integer :display_order
      t.boolean :is_exclusive # If set it causes some UI trigger to remove (and disable) all the other answer choices selected for a question (needed for the WHR)
      t.boolean :hide_label
      t.integer :display_length # if smaller than answer.length the html input length will be this value

      t.string :custom_class
      t.string :custom_renderer

      t.timestamps

    end
  end

  def self.down
    drop_table :answers
  end
end
