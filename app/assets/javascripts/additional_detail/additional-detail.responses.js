angular.module('app').factory("ServiceRequest",  ['$resource', function($resource) {
  // service_request_id is a global variable set in a HAML file
  return $resource("/additional_detail/service_requests/:id", {id: service_request_id});
}]);

angular.module('app').factory("Service",  ['$resource', function($resource) {
  // service_id is a global variable set in a HAML file
  return $resource("/additional_detail/services/:id", {id: service_id});
}]);

angular.module('app').factory("AdditionalDetail",  ['$resource', function($resource) {
  // service_id is a global variable set in a HAML file
  return $resource("/additional_detail/services/:service_id/additional_details/:id", 
		  {service_id: service_id, id: '@id'}, 
		  {
		    'export_grid': { method: 'GET', isArray: true, url: '/additional_detail/services/:service_id/additional_details/:id/export_grid'} ,
		    'update_enabled': { method: 'PUT', url: '/additional_detail/services/:service_id/additional_details/:id/update_enabled'}
		  });
}]);

angular.module('app').factory("LineItemAdditionalDetail",  ['$resource', function($resource) {
  return $resource("/additional_detail/line_item_additional_details/:id", { id: '@id'}, {'update': { method: 'PUT'} });
}]);

// define a base controller that features the $scope.showSurvey function that will be reused by customers and administrators
angular.module('app').controller("ShowSurveyController", ['$scope', 'LineItemAdditionalDetail', function($scope, LineItemAdditionalDetail) { 
	$scope.showSurvey = function(id){
		// hide the alert message before showing a survey
		$scope.alertMessage = null;
		// We need to load the survey data from this controller because it authorizes the current user to view it.
		LineItemAdditionalDetail.get({ id: id }).$promise.then(function(line_item_additional_detail) {
			$scope.currentLineItemAD = line_item_additional_detail;			
			$('#additionalDetailModal').modal();
		}, function errorCallback(error) { 
	    	 $scope.alertMessage = error.statusText;
	    	 $scope.resourceSuccessful = false;
	    });
	};
}]);

angular.module('app').controller("DocumentManagementAdditionalDetailsController", ['$scope', 'ServiceRequest', 'LineItemAdditionalDetail', '$controller', function($scope, ServiceRequest, LineItemAdditionalDetail, $controller) { 
	// extend the ShowSurveyController to share the $scope.showSurvey function
	angular.extend(this, $controller('ShowSurveyController', {$scope: $scope}));
	// extend the ConditionalQuestionsFormController to gain access to the conditional question functions
	// logic for conditional questions is not ready to be used because it needs fine tuning and testing 
	// angular.extend(this, $controller('ConditionalQuestionsFormController', {$scope: $scope}));
	// extend the QuestionsFormController to gain access to basic question functions
	angular.extend(this, $controller('QuestionsFormController', {$scope: $scope}));
	
	$scope.gridModel = {enableColumnMenus: false, enableFiltering: false, enableColumnResizing: false, enableRowSelection: false, enableSorting: true, enableRowHeaderSelection: false, rowHeight: 45};
	$scope.gridModel.columnDefs = [{name: 'Add/Edit Buttons', displayName:'', enableSorting: false, width: 105, cellTemplate: '<button type="button" class="btn btn-primary" ng-click="grid.appScope.showSurvey(row.entity.id)">{{(row.entity.form_data_json=="{}") ? "Add Details" : "Edit Details"}}</button>'},
	                               {field: 'additional_detail_breadcrumb', name: 'Service'}, 
	                               {name: 'Completed',field: 'has_answered_all_required_questions?', width: '15%' }];
	
	// initialize the service request and the grid
	$scope.serviceRequest = ServiceRequest.get( function() {
	   $scope.gridModel.data = $scope.serviceRequest.get_or_create_line_item_additional_details;
	});
	   
	$scope.saveFormResponse = function(){
		// convert the form response from an object to a string
		$scope.currentLineItemAD.form_data_json = JSON.stringify($scope.currentLineItemAD.form_data_hash);
		$scope.currentLineItemAD.$update(function(response) { 
			// reload the Service Request and the grid
			$scope.serviceRequest = ServiceRequest.get( function() {
			   $scope.gridModel.data = $scope.serviceRequest.get_or_create_line_item_additional_details;
			});
			$scope.alertMessage = "Response saved.";
			$scope.resourceSuccessful = true;
  	     }, function errorCallback(error) { 
  	    	$scope.alertMessage = error.statusText;
	        $scope.resourceSuccessful = false;
	     });
	};
		
	// dynamically change grid height relative to the # of rows of data, 
	//   only works if one grid is being displayed on the page
  	$scope.getTableHeight = function() {
        return {
        	height: (($scope.gridModel.data.length * $scope.gridModel.rowHeight) + $( ".ui-grid-header-cell-row" ).height() )+18 + "px"
        };
     };
}]);

angular.module('app').controller('AdditionalDetailsDisplayController', ['$scope', 'Service', 'AdditionalDetail', 'LineItemAdditionalDetail', 'uiGridConstants', 'uiGridExporterConstants', '$controller', function($scope, Service, AdditionalDetail, LineItemAdditionalDetail, uiGridConstants, uiGridExporterConstants, $controller) {
	// extend the ShowSurveyController to share the $scope.showSurvey function
	angular.extend(this, $controller('ShowSurveyController', {$scope: $scope}));
	// extend the ConditionalQuestionsFormController to gain access to the conditional question functions
	// logic for conditional questions is not ready to be used because it needs fine tuning and testing 
	// angular.extend(this, $controller('ConditionalQuestionsFormController', {$scope: $scope}));
	// extend the QuestionsFormController to gain access to basic question functions
	angular.extend(this, $controller('QuestionsFormController', {$scope: $scope}));
	
	$scope.gridModel = {enableColumnMenus: false, enableFiltering: true, enableRowSelection: false, enableSorting: true, enableRowHeaderSelection: false, rowHeight: 45};
	$scope.gridModel.columnDefs = [
	                               {enableFiltering: false, enableColumnResizing: false, width: 215,  name: 'Additional Detail Form',  cellTemplate: '<a class="btn btn-primary" href="/additional_detail/services/'+service_id+'/additional_details/{{row.entity.id}}/duplicate">Duplicate</a> <a class="btn btn-primary" ng-if="row.entity.line_item_additional_details.length == 0" href="/additional_detail/services/'+service_id+'/additional_details/{{row.entity.id}}/edit">Edit</a> <button class="btn btn-danger" ng-if="row.entity.line_item_additional_details.length == 0" ng-click="grid.appScope.deleteAdditonalDetail(row.entity)">Delete</button>'},
	                               {enableFiltering: false, enableColumnResizing: false, width: 130, name: "Responses",  cellTemplate: '<button class="btn btn-info" ng-disabled="row.entity.line_item_additional_details.length==0" ng-click="grid.appScope.updateLineItemAdditionalDetails(row.entity.id)">Responses <span class="badge">{{row.entity.line_item_additional_details.length}}</span></button>'},
	                               {field: 'name', name: 'Name', width: '25%'}, 
	                               {field:'effective_date',name: 'Effective Date', width: '15%',  sort: { direction: uiGridConstants.DESC, priority: 1 } },
	                               {field: 'enabled',name: 'Enabled', cellTemplate: '<label>Enabled <input type="checkbox" ng-change="grid.appScope.updateAdditionalDetail(row.entity)" ng-model="row.entity.enabled"/></label>'},
	                               {field: 'description', name: 'Description'}
	                               ];
	
	$scope.line_item_ad_gridModel = {enableColumnMenus: false, enableFiltering: true, enableRowSelection: false, enableSorting: true, enableRowHeaderSelection: false, rowHeight: 45};
	$scope.line_item_ad_gridModel.columnDefs = [
	                               {name: "Response", enableFiltering: false, width: 125, cellTemplate: '<button data-toggle="modal" class="btn btn-primary" ng-click="grid.appScope.showResults(row.entity.id)">Show</button> <button data-toggle="modal" class="btn btn-primary" ng-click="grid.appScope.showSurvey(row.entity.id)">Edit</button>'},
	                               {name: "Portal Admin", field: "sub_service_request_id", enableFiltering: false, width: 115, cellTemplate: '<a class="btn btn-info" href="/portal/admin/sub_service_requests/{{COL_FIELD}}" role="button">Portal Admin</a>'},
	                               {name: "SRID", field: "srid"},
	                               {name: "Principal Investigator", field: "pi_name", width: '15%'},
	                               {name: "Requester", field: "service_requester_name", width: '15%'},
	                               {name: "Short Title", field: "protocol_short_title", cellTooltip: true, width: '20%'},
	                               {name: 'Status', field: 'sub_service_request_status', headerTooltip: 'Service Request Status', width: '8%'}, 
	                               {name: 'Required Questions Answered',field: 'has_answered_all_required_questions?', headerTooltip: 'Required Questions Answered'},
	                               {field:'last_updated', sort: { direction: uiGridConstants.DESC, priority: 1 }, width: '12%' }
	                               ];
	// don't define columns for the export grid so that it will dynamically include the custom keys from additional details
	// Angular UI Grid supports PDF export but it's turned off to keep things simple.
	$scope.line_item_export_gridModel = {enableGridMenu: true, exporterMenuPdf: false, enableFiltering: true, enableSorting: true, enableRowHeaderSelection: false, rowHeight: 45,
	  onRegisterApi: function(line_item_export_gridApi){ 
	    $scope.line_item_export_gridApi = line_item_export_gridApi;
	  }
	};
	
	$scope.updateLineItemAdditionalDetails = function(ad_id){
		// hide the alert message before results
		$scope.alertMessage = null;
		AdditionalDetail.get({ id: ad_id }).$promise.then(function(additional_detail) {
			$scope.activeAdditionalDetail = additional_detail;
			$scope.line_item_ad_gridModel.data = additional_detail.line_item_additional_details;
			// activate the the results tab
			$('#resultsTab').attr('data-toggle', 'tab');
			$('#myTabs a[href="#liadGrid"]').tab('show');
			// update the export grid's downloadable CSV filename
			$scope.line_item_export_gridModel.exporterCsvFilename = additional_detail.name + ".csv";
		}, function errorCallback(error) { 
			// failed server side request
			$scope.alertMessage = error.statusText;
			$scope.resourceSuccessful = false;
	    }); 
        // load the export grid
		AdditionalDetail.export_grid({ id: ad_id }, {}).$promise.then(function(line_item_additional_details_export) {
			$scope.line_item_export_gridModel.data = line_item_additional_details_export;
		}, function errorCallback(error) { 
			// failed server side request
			$scope.alertMessage = error.statusText;
			$scope.resourceSuccessful = false;
	    }); 
	};
	
	$scope.export = function(){
	  // all columns and all rows
	  $scope.line_item_export_gridApi.exporter.csvExport(uiGridExporterConstants.ALL, uiGridExporterConstants.ALL);
    };
	  
	// initialize the service
	$scope.service = Service.get();
	// initialize the main grid
	$scope.gridModel.data = AdditionalDetail.query();
	
    $scope.updateAdditionalDetail = function(additionalDetail) {
    	additionalDetail.$update_enabled(function() { 
  			// reload the Service
    		$scope.service = Service.get();
  			$scope.alertMessage = "Additional Detail updated.";
  	        $scope.resourceSuccessful = true;
  		}, function errorCallback(error) { 
  			$scope.resourceSuccessful = false;
  	        $scope.alertMessage = error.statusText;
  	        // reload data into Grid
  			$scope.gridModel.data = AdditionalDetail.query();
  	    });
  	};
  	
    $scope.deleteAdditonalDetail = function(additionalDetail) {
    	additionalDetail.$delete(function() { 
    		// reload the Service
    		$scope.service = Service.get();
  			// reload data into Grid
  			$scope.gridModel.data = AdditionalDetail.query();
  			$scope.alertMessage = "Additional Detail deleted.";
  	        $scope.resourceSuccessful = true;
  		}, function errorCallback(error) { 
  	        $scope.alertMessage = error.statusText;
  	        $scope.resourceSuccessful = false;
  	    });
  	};
  	
  	$scope.showResults = function(liad_id){
		// hide the alert message before showing a survey
		$scope.alertMessage = null;
		// We need to load the survey data from this controller because it authorizes the current user to view it.
		LineItemAdditionalDetail.get({ id: liad_id }).$promise.then(function(line_item_additional_detail) {
			$scope.currentLineItemAD = line_item_additional_detail;
			$('#additionalDetailResultsModal').modal();
		}, function errorCallback(error) { 
	    	 $scope.alertMessage = error.statusText;
	    	 $scope.resourceSuccessful = false;
	    }); 
	}
  	
	$scope.saveFormResponse = function(){
		// convert the form response from an object to a string
		$scope.currentLineItemAD.form_data_json = JSON.stringify($scope.currentLineItemAD.form_data_hash);
		$scope.currentLineItemAD.$update(function() { 
			// refresh the response and export grids
			$scope.updateLineItemAdditionalDetails($scope.currentLineItemAD.additional_detail_id);
			$scope.alertMessage = "Response saved.";
			$scope.resourceSuccessful = true;
  	     }, function errorCallback(error) { 
  	        // failed server side validation
  	    	$scope.alertMessage = error.statusText;
 	        $scope.resourceSuccessful = false;
	     });
	}	
}]);