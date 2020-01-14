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

class Document < ApplicationRecord
  include Paperclip::Glue

  audited

  SUPPORTED_FILE_TYPES = [
    /\.pdf$/i,  /\.docx?$/i,  /\.xlsx?$/i,  /\.rtf$/i,
    /\.txt$/i,  /\.csv$/i,    /\.ppt?$/i,   /\.msg$/i,
    /\.eml$/i,  /\.jpg$/i,    /\.gif$/i,    /\.png$/i,
    /\.tiff$/i, /\.jpeg$/i
  ]

  belongs_to :protocol

  has_and_belongs_to_many :sub_service_requests
  has_many :organizations, through: :sub_service_requests
  
  has_attached_file :document #, :preserve_files => true

  validates_attachment_file_name :document, matches: Document::SUPPORTED_FILE_TYPES

  validates :doc_type, :document, presence: true
  validates :doc_type_other, presence: true, if: Proc.new { |doc| doc.doc_type == 'other' }

  def display_document_type
    self.doc_type == "other" ? self.doc_type_other : PermissibleValue.get_value('document_type', self.doc_type)
  end

  def all_organizations
    sub_service_requests.map(&:org_tree).flatten.uniq
  end
end
