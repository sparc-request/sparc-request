module DocumentsHelper

  def display_document_type doc
    if doc.doc_type == 'other'
      return doc.try(:doc_type_other).try(:humanize)
    else
      return DOCUMENT_TYPES.key doc.doc_type
    end
  end

end