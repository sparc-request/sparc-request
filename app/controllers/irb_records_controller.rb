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

class IrbRecordsController < ApplicationController
  before_action :find_protocol
  before_action :find_human_subjects_info
  before_action :find_irb_record,           only: [:edit, :update, :destroy]

  def new
    respond_to :js

    @irb_record = @human_subjects_info.irb_records.new
  end

  # Soft create builds hidden fields to submit on the potocol form
  def create
    respond_to :js

    @irb_record = @human_subjects_info.irb_records.new(irb_record_params)

    unless @irb_record.valid?
      @errors = @irb_record.errors
    end
  end

  def edit
    respond_to :js

    @irb_record.assign_attributes(irb_record_params) if params[:irb_record]
  end

  # Soft update builds hidden fields to submit on the potocol form
  def update
    respond_to :js

    @irb_record.assign_attributes(irb_record_params)

    unless @irb_record.valid?
      @errors = @irb_record.errors
    end
  end

  # Soft destroy builds hidden fields to submit on the potocol form
  def destroy
    respond_to :js
  end

  protected

  def find_protocol
    @protocol = params[:protocol_id].present? ? Protocol.find(params[:protocol_id]) : Study.new
  end

  def find_human_subjects_info
    @human_subjects_info = @protocol.human_subjects_info || @protocol.build_human_subjects_info
  end

  def find_irb_record
    @irb_record = params[:id].present? ? IrbRecord.find(params[:id]) : @human_subjects_info.irb_records.new
  end

  def irb_record_params
    params[:irb_record][:initial_irb_approval_date] = sanitize_date params[:irb_record][:initial_irb_approval_date]
    params[:irb_record][:irb_approval_date]         = sanitize_date params[:irb_record][:irb_approval_date]
    params[:irb_record][:irb_expiration_date]       = sanitize_date params[:irb_record][:irb_expiration_date]

    params.require(:irb_record).permit(
      :pro_number,
      :irb_of_record,
      :submission_type,
      :approval_pending,
      :initial_irb_approval_date,
      :irb_approval_date,
      :irb_expiration_date,
      study_phase_ids: []
    )
  end
end
