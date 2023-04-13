# Copyright © 2011-2022 MUSC Foundation for Research Development
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

  audited

  SUPPORTED_FILE_TYPES = [
    /\.pdf$/i,  /\.docx?$/i, /\.xlsx?$/i, /\.txt$/i,
    /\.csv$/i,  /\.ppt?$/i,  /\.msg$/i,   /\.eml$/i,
    /\.jpg$/i,  /\.gif$/i,   /\.png$/i,   /\.tiff$/i,
    /\.jpeg$/i
  ]

  belongs_to :protocol

  has_and_belongs_to_many :sub_service_requests
  has_many :organizations, through: :sub_service_requests
  
  has_one_attached :document, dependent: :destroy

  validates :doc_type, :document, presence: true
  validates :doc_type_other, presence: true, if: Proc.new { |doc| doc.doc_type == 'other' }

  validate :document_attached

  validate :supported_file_types

  def display_document_type
    self.doc_type == "other" ? self.doc_type_other : PermissibleValue.get_value('document_type', self.doc_type)
  end

  def all_organizations
    if self.share_all?
      self.protocol.sub_service_requests.map(&:org_tree).flatten.uniq
    else
      self.sub_service_requests.map(&:org_tree).flatten.uniq
    end
  end

  private

  def document_attached
    if !document.attached?
      errors.add :document, 'You must select a file.'
    end
  end

  def supported_file_types
    if document.attached? && !document.content_type.in?(%w(application/pdf application/vnd.openxmlformats-officedocument.wordprocessingml.document application/vnd.openxmlformats-officedocument.spreadsheetml.sheet text/plain text/csv application/vnd.ms-powerpoint application/vnd.ms-outlook message/rfc822 image/jpeg image/gif image/png image/tiff))
      document.purge_later
      errors.add(:document, 'file type is not supported.')
    end
  end
end
