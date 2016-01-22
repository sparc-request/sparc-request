date/time picker add-on
=================

This date/time picker add-on uses the angular-strap plugin to provide a datepicker or a timepicker interface. [angular-strap](http://mgcrea.github.io/angular-strap) is used.

This add-on takes options object via `dateOptions, timeOptions and options` in the form. More info below at [Options](#Options).

Installation
------------
The editor is an add-on to the Bootstrap decorator. To use it, just include
`schema-form-date-time-picker.min.js`.

Easiest way is to install is with bower, this will also include dependencies:
```bash
$ bower install chengz/schema-form-datetimepicker
```

You'll need to load a few additional files to use the editor:

**Be sure to load this projects files after you load angular schema form**

Example

```HTML
<script type="text/javascript" src="/bower_components/angular/angular.min.js"></script>
<script src="bower_components/angular-sanitize/angular-sanitize.min.js"></script>
<script src='bower_components/angular-strap/dist/angular-strap.min.js'></script>
<script src='bower_components/angular-strap/dist/angular-strap.tpl.min.js'></script>
<script src="bower_components/tv4/tv4.js"></script>
<script src="bower_components/objectpath/lib/ObjectPath.js"></script>
<script src="bower_components/angular-schema-form/dist/schema-form.min.js"></script>
<script src="bower_components/angular-schema-form/dist/bootstrap-decorator.min.js"></script>
<script src="schema-form-date-time-picker.js"></script>
```

When you create your module, be sure to depend on this project's module as well.

```javascript
angular.module('yourModule', ['schemaForm', 'schemaForm-datepicker', 'schemaForm-timepicker', 'schemaForm-datetimepicker']);
```

Usage
-----
The add-on adds three new form type, `datepicker, timepicker, datetimepicker`, and three new default
mappings.

| Schema             |   Default Form type  |
|:-------------------|:------------:|
| "type": "string" and "format": "datepicker"   |   datepicker   |
| "type": "string" and "format": "timepicker"   |   timepicker   |
| "type": "string" and "format": "datetimepicker"   |   datetimepicker   |


Options
-------

### datepicker

The `datepicker` form takes one option, `dateOptions`. This is an object with any
and all options availible to angular-strap datepicker.

**Example**

```javascript
{
  "key": "publish_date",
  "dateOptions": {
    "minDate": new Date(),
    "maxDate": $scope.$eval("model.some_other_date")
  }
},
```

### timepicker

The `timepicker` form takes one option, `timeOptions`. This is an object with any
and all options availible to angular-strap timepicker.

**Example**

```javascript
{
  "key": "publish_time",
  "dateOptions": {
    "minuteStep": 15,
    "autoclose": 1
  }
},
```

### datetimepicker

The `datetimepicker` form takes one option, `options`. This is an object with any
and all options availible to angular-strap datepicker and timepicker.

**Example**

```javascript
{
  "key": "publish_at",
  "options": {
    "minDate": new Date(),
    "minuteStep": 15,
    "autoclose": 1
  }
},
```
