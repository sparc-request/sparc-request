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

var FormFxManager;
FormFxManager = {
  registerListeners: function(el, atts) {
    var done_ran, inputs;
    inputs = _.memoize(function(key) {
      return FormFxManager.getSelector(el, key);
    });
    done_ran = {};
    return _.each(_.keys(atts), function(key) {
      var hide_deps, refresh_deps;
      hide_deps = function(key) {
        var dependents, vals;
        done_ran[key] = true;
        vals = atts[key];
        dependents = _.union.apply(_, _.values(atts[key]));
        return _.each(dependents, function(d) {
          inputs(d).hide();
          if (atts[d]) {
            return hide_deps(d);
          }
        });
      };
      refresh_deps = function(key) {
        var dependents, should_be_hidden, should_be_visible, val, vals;
        done_ran[key] = true;
        vals = atts[key];
        dependents = _.union.apply(_, _.values(atts[key]));
        val = FormFxManager.getValue(inputs(key));
        should_be_visible = vals[val];
        should_be_hidden = _.difference(dependents, vals[val]);
        _.each(should_be_visible, function(d) {
          inputs(d).show();
          if (atts[d]) {
            return refresh_deps(d);
          }
        });
        return _.each(should_be_hidden, function(d) {
          inputs(d).hide();
          if (atts[d]) {
            return hide_deps(d);
          }
        });
      };
      inputs(key).change(function() {
        return refresh_deps(key);
      });
      if (!done_ran[key]) {
        return refresh_deps(key);
      }
    });
  },
  getSelector: function(el, selector) {
    var class_name, garbage, name, sel, selector_id, _ref;
    _ref = selector.match(/(^\..*)|(^\#.*)|(^.*)/), garbage = _ref[0], class_name = _ref[1], selector_id = _ref[2], name = _ref[3];
    if (name) {
      sel = $(el).find("[name='" + name + "']");
    } else {
      sel = $(el).find(class_name || selector_id);
    }
    assert(sel && (sel.length > 0), "FormFxManager.getSelector: could not find element for key " + selector);
    return sel;
  },
  getValue: function(input) {
    if (input.is(':checkbox')) {
      if (input.is(':checked')) {
        return 'true';
      } else {
        return 'false';
      }
    } else if (input[0].tagName === "SELECT") {
      return input.find("option:selected").val();
    } else if (input.is("[type=text]")) {
      if (input.val().length > 0) {
        return 'true';
      } else {
        return 'false';
      }
    } else {
      return input.val();
    }
  }
};
