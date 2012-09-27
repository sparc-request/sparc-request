# FormManager
# -----------
# Intends to take the complexity out of applying values from an
# object into the values for a form, and then pulling those values back out
# for persistance or change.
#
# Expects two parameters:
#
# 1. `@el` as a jquery selector
# 2. `@atts` as a map from keys on the object to html selector/name/etc
#
# `@atts` may be in two forms, either as a simple map with a pointer
# from the `model_attribute` to a DOM selector or as a complex map from
# a model attribute to a map of options:
#
# Options
# -------
#
#  `require_visible` :
#   The `require_visible` key can be added to the more complex map,
#   that will verify the input is in a visible state before passing the key,
#   this is largely designed to be programatically added to the map if you want
#   to be able to make the form smart about which keys to set and unset
#   before persisting to the db.
#
#   `atts = {"short_title" : "short-title"}`
#
#   `atts = { short_title : {selector : "short-title", require_visible : true}}`
#
#  `is_nested`:
#   Currently nesting is only supported with the name attribute for anything
#   jQuery can match with the `:input` selector.
#   Nesting is to provide magical transporation to nested attributes on the
#   model without having to specfically handle that in the View code.
#   Naming convetion of the inputs will take the pattern:
#   `object[attribute]` where the `val()` will provide the option
#   Currently only supports textboxes (the main use case) and select tags,
#   but not multiselect (as far as I know). See Specs for better use case
#   descriptions.
#
#  `data_type`:
#   Basic type casting. Currently supported values are "number" and "integer"
#
#  `formatter`:
#   Formatter option is expected to be an object with two functions
#   
#   1. to_form
#   2. from_form
#
#   Takes a single argument which will be the value to be formatted and then
#   returns the properly formatted string.

FormManager =

  populate : (ob, el, atts)->
    _.each _.keys(atts), (key) =>
      # normalize the default case to a map
      val = atts[key]
      @el = el
      if val.is_nested == true
        for k,v of ob[key]
          sel = "#{val.selector}[#{k}]"
          @toForm(@getInput(sel), v, atts[key]['formatter'])
      else
        if _.isString(val)
          val = {selector : val}
        @toForm(@getInput(@detectSelector(val)), ob[key], atts[key]['formatter'])

  extract: (el, atts)->
    @el = el
    ob = {}
    _.each _.keys(atts), (key)=>

      # the attribute is defined by the map to only be saved if it is visible
      # or it is defined by the map to capture the attribute in either visible state
      require_visible = atts[key]['require_visible']
      data_type       = atts[key]['data_type']
      formatter       = atts[key]['formatter']
      if atts[key].is_nested == true
        inputs = $(@el).find(":input[name^='#{key}']")
        assert inputs.length >= 1,
          "there were no form inputs with a name attribute supporting nesting"

        # this is pretty magical and could backfire at some point
        # it expects that the form will have an input with a name attribute
        # and that its form will be `name = 'object[attribute]'`
        _.each inputs, (i)=>
          key = $(i).attr('name')
          val = @fromForm($(i), require_visible, data_type)
          if formatter and _.isFunction(formatter.from_form)
            val = formatter.from_form(val)
          [garbage, attr, option] = key.match(/(\w+)\[(\w+)\]/)
          if _.isUndefined(ob[attr])
            ob[attr] = {}
          ob[attr][option] = val

      # the good news is that most things don't need to be nested
      else
        val = atts[key]
        if _.isString val
          val = {selector : val }
        selector = @detectSelector val
        input = @getInput(selector)
        value = @fromForm(input, require_visible, data_type)
        if formatter and _.isFunction(formatter.from_form)
          value = formatter.from_form(value)
        ob[key] = value
    ob

  toForm : (input,value,formatter)->
    if input.is(':checkbox')
      input.prop('checked', value)
    else if input.is(':text') or input[0].tagName == "TEXTAREA"
      if formatter and _.isFunction(formatter.to_form)
        value = formatter.to_form(value)
      input.val value
    else if input[0].tagName == "SELECT"
      input.find("option[value='#{value}']").prop("selected", true)

  fromForm : (input, require_visible, data_type)->
    if (require_visible and input.is(':visible'))  or  !require_visible
      if input.is(':text') or input[0].tagName == "TEXTAREA"
        value = if data_type then @castValue(input.val(), data_type) else input.val()
      if input.is(':checkbox')
        value = input.is(":checked")
      if input[0].tagName == "SELECT"
        opt = input.find("option:selected")
        has_value_att = -> !!(opt[0].getAttribute('value'))
        value = if opt[0] and has_value_att() then opt.val() else undefined
      value

  castValue : (val, data_type)->
    switch data_type
      when "number"
        foo = parseFloat(val)
        if _.isNaN(foo) then 0 else foo
      when "integer"
        parseInt(val)

  getInput: (selector)->
    [garbage, class_name, selector_id, name] = selector.match /(^\..*)|(^\#.*)|(^.*)/
    if name
      input = $(@el).find(":input[name='#{name}']")
    else
      input = $(@el).find(":input#{class_name or selector_id}")
    assert input and (input.length > 0),
      "FormManager#getInput could not find an element to match the key #{selector}"
    input

  # this will probably get hairy at some point
  detectSelector: (value)->
    value['selector']