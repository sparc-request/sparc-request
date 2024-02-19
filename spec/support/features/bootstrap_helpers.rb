# Copyright © 2011-2022 MUSC Foundation for Research Development~
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

module Features
  module BootstrapHelpers
    def fill_in(id, opts={})
      field = page.find("##{id}")
      field.click
      field.send_keys(:delete)
      field.set(opts[:with])
    end

    def bootstrap_select(class_or_id, choice)
      retries = 0
      begin
        retries ||= 0
        expect(page).to have_selector(".bootstrap-select select#{class_or_id} + .dropdown-toggle")
        bootstrap_select = page.first(".bootstrap-select select#{class_or_id} + .dropdown-toggle")
      rescue Selenium::WebDriver::Error::StaleElementReferenceError, Capybara::ElementNotFound
        sleep 1
        retry if (retries += 1) < 5
      end

      bootstrap_select.click

      expect(page).to have_selector('.dropdown-menu.show')
      first('.dropdown-menu.show span.text', text: choice).click
      wait_for_javascript_to_finish
    end

    def bootstrap_multiselect(class_or_id, selections = ['all'])
      retries = 0
      begin
        retries ||= 0
        expect(page).to have_selector(".bootstrap-select select#{class_or_id} + .dropdown-toggle")
        bootstrap_multiselect = page.first(".bootstrap-select select#{class_or_id} + .dropdown-toggle")
      rescue Selenium::WebDriver::Error::StaleElementReferenceError, Capybara::ElementNotFound
        sleep 1
        retry if (retries += 1) < 5
      end
      
      bootstrap_multiselect.click

      expect(page).to have_selector('.dropdown-menu.show')
      if selections.first == 'all'
        first('.dropdown-menu.show span.text', text: 'Select all').click
      else
        selections.each do |selection|
          first('.dropdown-menu.show span.text', text: selection).click
        end
      end
      first('h4', text: 'Test').click # Click away
      wait_for_javascript_to_finish
    end

    def bootstrap_selected?(element, choice)
      page.find("button.selectpicker[data-id='#{element}'][title='#{choice}']")
    end

    def bootstrap_dropdown(class_or_id, choice)
      find(class_or_id).click
      find("#{class_or_id} + .dropdown-menu.show .dropdown-item", text: choice).click
    end

    def bootstrap_datepicker(element, text)
      field = page.find(element)
      field.click
      field.send_keys(:delete)
      field.set(text)
      first('h4', text: 'Test').click # Click away
      wait_for_javascript_to_finish
    end

    def bootstrap_toggle(id)
      # The input is inside the toggle, so get the parent using xpath
      find("#{id}", visible: false).find(:xpath, '..').click
    end

    def bootstrap_typeahead(selector, text)
      field = find("input#{selector}.tt-input")
      field.click
      field.send_keys(:delete)
      field.set(text)
      wait_for_javascript_to_finish
      expect(page).to have_selector('.tt-suggestion.tt-selectable', visible: false)
      field.send_keys :down
      find('.tt-menu.tt-open').first('.tt-suggestion').click
      wait_for_javascript_to_finish
    end


    # Bootstrap 3 Helpers for Catalog Manager

    def bootstrap3_select(class_or_id, choice)
      expect(page).to have_selector(".bootstrap-select select#{class_or_id} + .dropdown-toggle")
      bootstrap_select = page.first(".bootstrap-select select#{class_or_id} + .dropdown-toggle")
      bootstrap_select.click

      expect(page).to have_selector('.dropdown-menu.open')
      first('.dropdown-menu.open span.text', text: choice).click
      wait_for_javascript_to_finish
    end

    def bootstrap3_multiselect(class_or_id, selections = ['all'])
      expect(page).to have_selector(".bootstrap-select select#{class_or_id} + .dropdown-toggle")
      bootstrap_multiselect = page.first(".bootstrap-select select#{class_or_id} + .dropdown-toggle")
      bootstrap_multiselect.click

      expect(page).to have_selector('.dropdown-menu.open')
      if selections.first == 'all'
        first('.dropdown-menu.open span.text', text: 'Select all').click
      else
        selections.each do |selection|
          first('.dropdown-menu.open span.text', text: selection).click
        end
      end
      first('h4', text: 'Test').click # Click away
      wait_for_javascript_to_finish
    end

    def bootstrap3_datepicker(element)
      e = page.find(element)
      e.click
      e.set(Date.today.strftime('%Y-%m-%d'))
      find(".dropdown-menu td.today").click
    end
  end
end
