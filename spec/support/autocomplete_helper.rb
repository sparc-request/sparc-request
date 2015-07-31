module AutocompleteHelper
  # Fill jquery autocomplete field with options[:with] and
  # exposes dropdown with options for you to click.
  # See features/projects_submit_spec.rb for an example.
  def fill_autocomplete(field, options = {})
    page.execute_script %Q{ $('##{field}').autocomplete('search', '#{options[:with]}') }
    selector = %Q{ul.ui-autocomplete li.ui-menu-item a:contains('#{options[:with]}')}
    expect(page).to have_css('ul.ui-autocomplete li.ui-menu-item a')
    page.execute_script %Q{ $("##{selector}").trigger('mouseenter') }
  end
end

RSpec.configure do |config|
  config.include AutocompleteHelper
end
