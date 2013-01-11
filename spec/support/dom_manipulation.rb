def remove_from_dom(css)
  page.execute_script("$('#{css}').remove()")
end
