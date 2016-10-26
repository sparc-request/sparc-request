// Copyright © 2011-2016 MUSC Foundation for Research Development
// All rights reserved.

// Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

// 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

// 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
// disclaimer in the documentation and/or other materials provided with the distribution.

// 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
// derived from this software without specific prior written permission.

// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
// BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
// SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
// TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

var FormManager;
var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
FormManager = {
  populate: function(ob, el, atts) {
    return _.each(_.keys(atts), __bind(function(key) {
      var k, sel, v, val, _ref, _results;
      val = atts[key];
      this.el = el;
      if (val.is_nested === true) {
        _ref = ob[key];
        _results = [];
        for (k in _ref) {
          v = _ref[k];
          sel = "" + val.selector + "[" + k + "]";
          _results.push(this.toForm(this.getInput(sel), v, atts[key]['formatter']));
        }
        return _results;
      } else {
        if (_.isString(val)) {
          val = {
            selector: val
          };
        }
        return this.toForm(this.getInput(this.detectSelector(val)), ob[key], atts[key]['formatter']);
      }
    }, this));
  },
  extract: function(el, atts) {
    var ob;
    this.el = el;
    ob = {};
    _.each(_.keys(atts), __bind(function(key) {
      var data_type, formatter, input, inputs, require_visible, selector, val, value;
      require_visible = atts[key]['require_visible'];
      data_type = atts[key]['data_type'];
      formatter = atts[key]['formatter'];
      if (atts[key].is_nested === true) {
        inputs = $(this.el).find(":input[name^='" + key + "']");
        assert(inputs.length >= 1, "there were no form inputs with a name attribute supporting nesting");
        return _.each(inputs, __bind(function(i) {
          var attr, garbage, option, val, _ref;
          key = $(i).attr('name');
          val = this.fromForm($(i), require_visible, data_type);
          if (formatter && _.isFunction(formatter.from_form)) {
            val = formatter.from_form(val);
          }
          _ref = key.match(/(\w+)\[(\w+)\]/), garbage = _ref[0], attr = _ref[1], option = _ref[2];
          if (_.isUndefined(ob[attr])) {
            ob[attr] = {};
          }
          return ob[attr][option] = val;
        }, this));
      } else {
        val = atts[key];
        if (_.isString(val)) {
          val = {
            selector: val
          };
        }
        selector = this.detectSelector(val);
        input = this.getInput(selector);
        value = this.fromForm(input, require_visible, data_type);
        if (formatter && _.isFunction(formatter.from_form)) {
          value = formatter.from_form(value);
        }
        return ob[key] = value;
      }
    }, this));
    return ob;
  },
  toForm: function(input, value, formatter) {
    if (input.is(':checkbox')) {
      return input.prop('checked', value);
    } else if (input.is(':text') || input[0].tagName === "TEXTAREA") {
      if (formatter && _.isFunction(formatter.to_form)) {
        value = formatter.to_form(value);
      }
      return input.val(value);
    } else if (input[0].tagName === "SELECT") {
      return input.find("option[value='" + value + "']").prop("selected", true);
    }
  },
  fromForm: function(input, require_visible, data_type) {
    var has_value_att, opt, value;
    if ((require_visible && input.is(':visible')) || !require_visible) {
      if (input.is(':text') || input[0].tagName === "TEXTAREA") {
        value = data_type ? this.castValue(input.val(), data_type) : input.val();
      }
      if (input.is(':checkbox')) {
        value = input.is(":checked");
      }
      if (input[0].tagName === "SELECT") {
        opt = input.find("option:selected");
        has_value_att = function() {
          return !!(opt[0].getAttribute('value'));
        };
        value = opt[0] && has_value_att() ? opt.val() : void 0;
      }
      return value;
    }
  },
  castValue: function(val, data_type) {
    var foo;
    switch (data_type) {
      case "number":
        foo = parseFloat(val);
        if (_.isNaN(foo)) {
          return 0;
        } else {
          return foo;
        }
        break;
      case "integer":
        return parseInt(val);
    }
  },
  getInput: function(selector) {
    var class_name, garbage, input, name, selector_id, _ref;
    _ref = selector.match(/(^\..*)|(^\#.*)|(^.*)/), garbage = _ref[0], class_name = _ref[1], selector_id = _ref[2], name = _ref[3];
    if (name) {
      input = $(this.el).find(":input[name='" + name + "']");
    } else {
      input = $(this.el).find(":input" + (class_name || selector_id));
    }
    assert(input && (input.length > 0), "FormManager#getInput could not find an element to match the key " + selector);
    return input;
  },
  detectSelector: function(value) {
    return value['selector'];
  }
};