# Copyright © 2011-2019 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

module NotesHelper
  def notes_button(notable, disabled=false)
    has_notes = notable.notes.length > 0

    content_tag(:button, type: 'button', class: 'btn btn-link no-padding notes', disabled: disabled, data: { notable_id: notable.id, notable_type: notable.class.name }) do
      content_tag(:span, '', class: ["glyphicon glyphicon-list-alt note-icon", has_notes ? "blue-note" : "black-note"], aria: {hidden: "true"}) +
      content_tag(:span, notable.notes.length, class: ["badge", has_notes ? "blue-badge" : ""], id: "#{notable.class.name.downcase}_#{notable.id}_notes")
    end
  end

  def note_actions(note)
    [
      edit_note_button(note),
      delete_note_button(note)
    ].join('')
  end

  def edit_note_button(note)
    link_to edit_note_path(note, note: { notable_id: note.notable_id, notable_type: note.notable_type }, cancel: params[:cancel], review: params[:review]), remote: true, class: ['btn btn-warning', note.identity_id == current_user.id ? '' : 'disabled'] do
      content_tag(:span, '', class: 'glyphicon glyphicon-edit', aria: {hidden: "true"})
    end
  end

  def delete_note_button(note)
    content_tag(:button, type: 'button', class: ['btn btn-danger delete-note', note.identity_id == current_user.id ? '' : 'disabled'], data: { note_id: note.id } ) do
      content_tag(:span, '', class: 'glyphicon glyphicon-remove', aria: {hidden: "true"})
    end
  end

  def note_header(notable)
    action = ['create', 'update'].include?(action_name) ? 'index' : action_name

    header =
      if notable.is_a?(EpicQueueRecord)
        t("notes.headers.#{action}", notable_type: "Epic Queue Record")
      elsif notable.is_a?(Protocol)
        t("notes.headers.#{action}", notable_type: "Protocol")
      elsif [LineItem, LineItemsVisit].include?(notable.class)
        t("notes.headers.#{action}", notable_type: "Service")
      else
        t("notes.headers.#{action}", notable_type: notable.class.name)
      end

    header += " | Study: #{notable.protocol_id}" if notable.is_a?(EpicQueueRecord)
    header += " | #{notable.service.display_service_name}" if [LineItem, LineItemsVisit].include?(notable.class)

    header
  end
end
