angular.module('app', ['ngResource','ngAria','schemaForm','ui.grid','ui.grid.selection', 'ui.grid.exporter', 'ui.grid.resizeColumns', 'mgcrea.ngStrap', 'schemaForm-datepicker', 'schemaForm-timepicker', 'schemaForm-datetimepicker','ngSanitize', 'ui.grid.autoResize','ui.grid.expandable', 'ui.grid.edit']);

angular.module('app').config([
     "$httpProvider", function($httpProvider) {
     $httpProvider.defaults.headers.common["Accept"] = "application/json";
     $httpProvider.defaults.headers.common["Content-Type"] = "application/json";
     $httpProvider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
     }]);

// Shared by the admin tools for responses and form creation
angular.module('app').factory("AdditionalDetail",  ['$resource', function($resource) {
  // service_id is a global variable set in a HAML file
  return $resource("/additional_detail/services/:service_id/additional_details/:id", 
		  {service_id: service_id, id: '@id'}, 
		  {
			'new': { method: 'GET', url: '/additional_detail/services/:service_id/additional_details/new'} ,  
		    'export_grid': { method: 'GET', isArray: true, url: '/additional_detail/services/:service_id/additional_details/:id/export_grid'} ,
		    'update_enabled': { method: 'PUT', url: '/additional_detail/services/:service_id/additional_details/:id/update_enabled'}
		  });
}]);