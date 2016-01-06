module Portal::DocumentsHelper

  def display_document_title document
    link_to document.document_file_name, document.document.url
  end

  def document_edit_button
    content_tag(:button,
      raw(
        content_tag(:span, '', class: "glyphicon glyphicon-edit", aria: {hidden: "true"})
      ), type: 'button', class: 'btn btn-warning actions-button document_edit'
    )
  end

  def document_delete_button
    content_tag(:button,
      raw(
        content_tag(:span, '', class: "glyphicon glyphicon-remove", aria: {hidden: "true"})
      ), type: 'button', class: 'btn btn-danger actions-button document_delete'
    )
  end
end
