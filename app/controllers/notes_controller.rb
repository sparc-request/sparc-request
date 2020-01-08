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

class NotesController < ApplicationController
  before_action :initialize_service_request,  unless: :in_dashboard?
  before_action :authorize_identity,          unless: :in_dashboard?
  before_action :authorize_dashboard_access,  if: :in_dashboard?
  before_action :find_note,                   only: [:edit, :update, :destroy]
  before_action :find_notable

  def index
    @notes    = @notable.notes
    @note     = current_user.notes.new(note_params)
    @disabled = params[:disabled] == 'true'

    respond_to :js
  end

  def create
    @note = current_user.notes.new(note_params)

    if @note.save
      @notes  = @notable.notes
      @note   = current_user.notes.new(notable_id: @notable_id, notable_type: @notable_type)
      @count  = helpers.format_count(@notes.count, 1)
    else
      @errors = @note.errors
    end

    respond_to :js
  end

  def edit
    respond_to :js
  end

  def update
    @notes = @notable.notes

    if @note.update_attributes(note_params)
      @notes  = @notable.notes
      @note   = current_user.notes.new(notable_id: @notable_id, notable_type: @notable_type)
    else
      @errors = @note.errors
    end

    respond_to :js
  end

  def destroy
    @selector = @note.unique_selector
    @note.destroy
    @notes    = @notable.notes
    @note     = current_user.notes.new(notable_id: @notable_id, notable_type: @notable_type)
    @count    = helpers.format_count(@notes.count, 1)

    respond_to :js
  end

  private

  def note_params
    params.require(:note).permit(:identity_id, :notable_type, :notable_id, :body)
  end

  def find_notable
    @notable_id   = @note ? @note.notable_id    : note_params[:notable_id]
    @notable_type = @note ? @note.notable_type  : note_params[:notable_type]
    @notable      = @note ? @note.notable       : @notable_type.constantize.find(@notable_id)
  end

  def find_note
    @note = Note.find(params[:id])
  end
end
