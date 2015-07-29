module AutocompleteHelper
  def fill_autocomplete(field, options = {})
    fill_in field, with: options[:with]
    page.execute_script %Q{ $('##{field}').trigger('focus') }
    page.execute_script %Q{ $('##{field}').trigger('keydown') }
    selector = %Q{ul.ui-autocomplete li.ui-menu-item a:contains('#{options[:with]}')}
    expect(page).to have_css('ul.ui-autocomplete li.ui-menu-item a')
    page.execute_script %Q{ $("##{selector}").trigger('mouseenter').click() }
  end
end

RSpec.configure do |config|
  config.include AutocompleteHelper
end
