module Dashboard
  module Notes
    class NewModal < SitePrism::Section
      element :input_field, 'textarea'
      element :add_note_button, 'input[value="Add"]'
    end
  end
end
