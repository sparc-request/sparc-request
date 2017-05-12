module Features

  module BootstrapHelpers

    def bootstrap_multiselect(class_or_id, selections = ['all'])
      bootstrap_multiselect = find("select#{class_or_id} + .btn-group")
      bootstrap_multiselect.click

      if selections.first == 'all'
        first('.dropdown-menu.open span.text', text: 'Select all').click
      else
        selections.each do |selection|
          first('.dropdown-menu.open span.text', text: selection).click
        end
      end
      find('body').click # Click away
      wait_for_javascript_to_finish
    end

    def bootstrap_select(class_or_id, choice)
      bootstrap_select = page.find("select#{class_or_id} + .bootstrap-select")

      bootstrap_select.click
      first('.dropdown-menu.open span.text', text: choice).click
      wait_for_javascript_to_finish
    end

    def bootstrap_selected?(element, choice)
      page.find("button.selectpicker[data-id='#{element}'][title='#{choice}']")
    end
  end
end
