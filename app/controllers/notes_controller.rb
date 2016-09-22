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

class NotesController < ApplicationController
  respond_to :js, :json

  before_action :find_notable
  before_action :set_in_dashboard

  def index
    respond_to do |format|
      format.js
      format.json {
        @notes = @notable.notes
      }
    end
  end

  def new
    @note = Note.new(note_params.merge(identity_id: current_user.id))
  end

  def create
    @note  = Note.create(note_params.merge(identity_id: current_user.id))
    @notes = @notable.notes

    if @note.valid?
      @selector = "#{@note.unique_selector}_notes"
      flash[:success] = t(:notes)[:created]
    else
      @errors = @note.errors
    end
  end

  private

  def note_params
    params.require(:note).permit(:identity_id, :notable_type, :notable_id, :body)
  end

  def find_notable
    @notable_id = params[:note][:notable_id]
    @notable_type = params[:note][:notable_type]
    @notable = @notable_type.constantize.find(@notable_id)
  end

  def set_in_dashboard
    @in_dashboard = params[:in_dashboard] == 'true'
  end
end
