module Dashboard
  module Notes
    class IndexModal < SitePrism::Section
      element :new_note_button, "button", text: "Add Note"

      elements :notes, ".detail"

      element :message_area, :field, "Note:"

      element :add_note_button, "input[type='submit']"
    end
  end
end
