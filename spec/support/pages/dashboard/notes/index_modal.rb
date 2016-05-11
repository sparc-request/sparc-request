module Dashboard
  module Notes
    class IndexModal < SitePrism::Section
      element :new_note_button, "button", text: "Add Note"

      # list of notes
      elements :notes, ".detail"

      # appears after clicking :new_note_button
      element :message_area, :field, "Note:"

      # send note button
      element :add_note_button, "input[type='submit']"
    end
  end
end
