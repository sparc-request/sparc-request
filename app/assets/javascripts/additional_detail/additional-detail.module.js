angular.module('app', ['ngResource','ngAria','schemaForm','ui.grid','ui.grid.selection', 'ui.grid.exporter', 'ui.grid.resizeColumns', 'mgcrea.ngStrap', 'schemaForm-datepicker', 'schemaForm-timepicker', 'schemaForm-datetimepicker','ngSanitize', 'ui.grid.autoResize','ui.grid.expandable', 'ui.grid.edit']);

angular.module('app').config([
     "$httpProvider", function($httpProvider) {
     $httpProvider.defaults.headers.common["Accept"] = "application/json";
     $httpProvider.defaults.headers.common["Content-Type"] = "application/json";
     $httpProvider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
     }]);