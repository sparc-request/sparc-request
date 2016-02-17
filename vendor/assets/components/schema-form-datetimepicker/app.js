/*global angular */
'use strict';

/**
 * The main app module
 * @name app
 * @type {angular.Module}
 */
var app = angular.module('app', ['schemaForm-datepicker', 'schemaForm-datetimepicker', 'schemaForm-timepicker'])
.controller('DateTimeController', function($scope){
  $scope.schema = {
    "type": "object",
    "title": "Story",
    "properties": {
      "title": {
        "title": "Title",
        "type": "string",
        "minLength": 10
      },
      "intro": {
        "title": "Introduction",
        "type": "string",
        "minLength": 10
      },
      "note": {
        "title": "Note",
        "type": "string",
        "minLength": 10
      },
      "to_be_published_at": {
        "title": "To be published at",
        "type": "object",
        "format": "datetimepicker"
      }
    },
    "required": [
      "title",
      "image"
    ]
  }
  $scope.schema2 = {
    type: 'object',
    title: 'DateTime',
    properties: {
      name: {
        title: 'Name',
        type: 'string'
      },
      date: {
        title: 'Date',
        type: 'string',
        format: 'datepicker',
        description: 'This is a date'
      },
      from_date: {
        title: 'From Date',
        type: 'string',
        format: 'datepicker'
      },
      to_date: {
        title: 'To Date',
        type: 'string',
        format: 'datepicker',
        default: '04/10/2014'
      },
      time: {
        title: 'Time',
        type: 'string',
        format: 'timepicker',
        description: 'This is a time'
      },
      'datetime': {
        'title': 'Date and Time',
        'type': 'object',
        'format': 'datetimepicker',
        'description': 'This is a date and time'
      },
      list: {
        type: "array",
        items: {
          type: "object",
          properties: {
            opening_date: {
              title: 'Opening date',
              type: 'string',
              format: 'datepicker',
              description: 'Opening date given here.',
              default: '04/10/2014'
            },
            opening_time: {
              title: 'Opening time',
              type: 'string',
              format: 'timepicker',
              description: 'Opening time mentioned here.',
            }
          }
        }
      }
    },
    required: ['date']
  };
  $scope.onSubmit = function(form) {
    $scope.$broadcast('schemaFormValidate')
    console.log(form.$valid);
    console.log($scope.model);
  }
  var minDate = new Date();
  var maxDate = new Date(minDate).addDays(5)
  //$scope.model = { date: minDate, time: new Date(minDate).addDays(1), from_date: minDate, to_date: maxDate, datetime: minDate };
  $scope.model = { to_be_published_at: new Date("2014-09-22 14:00:00.000") }
  $scope.form = [
    {
      'key': 'title',
      'placeholder': 'Title'
    },
    {
      'key': 'intro'
    },
    'note',
    {
      key: 'to_be_published_at',
      'options': {
        'autoclose': 1
      }
    },
     {
        type: "submit",
        style: "btn-info",
        title: "OK"
      }
  ]
  
  $scope.form2 = [
    'name',
     {
       key: 'date',
       dateOptions: {
         minDate: minDate,
         maxDate: maxDate,
         autoclose: "1",
         useNative: true
       }
     },
     {
       key: 'from_date',
       dateOptions: {
         maxDate: $scope.$eval('model.to_date'),
         autoclose: "1",
         useNative: true
       }
     },
     {
       key: 'to_date',
       dateOptions: {
         minDate: $scope.$eval('model.from_date'),
         autoclose: "1",
         useNative: true
       }
     },
     {
       key: 'time',
       timeOptions: {
         autoclose: false,
         minuteStep: "15"
       }
     },
     {
       key: 'datetime',
       options: {
         minDate: minDate,
         maxDate: maxDate,
         autoclose: "1",
         useNative: true,
         minuteStep: "15"
       }
     },
      { 
        key: 'list',
        items: [
          {
            "key": "list[].opening_date",
            default: '04/10/2014',
            "dateOptions": {
              "minDate": new Date(),
              autoclose: '1'
            }
          },
          {
            "key": "list[].opening_time",
            "dateOptions": {
              "minuteStep": 15
            }
          },
        ]
    
      },
     {
        type: "submit",
        style: "btn-info",
        title: "OK"
      }
  ];
});
