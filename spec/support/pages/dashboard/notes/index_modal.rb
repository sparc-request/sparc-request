module Dashboard
  module Notes
    class IndexModal < SitePrism::Section
      element :new_note_button, 'button.note.new'
      sections :notes, '.detail' do
        element :name, '.name'
        element :created_at, '.created-at'
        element :comment, '.comment'
      end
    end
  end
end
