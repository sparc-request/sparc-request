angular.module('app').factory("Identity",  ['$resource', function($resource) {
  return $resource("/admin/identities/:id", 
		  {id: '@id'}, 
		  {'update': { method: 'PUT'},
		   'search': { method: 'GET', isArray: true, url: '/admin/identities/search', params:{term: '@term'}}});
}]);

angular.module('app').controller("AdminUserSearchController", ['$scope', 'Identity',function($scope, Identity) { 
    $scope.search_term = "";
    $scope.search_in_progress= false;
	$scope.gridModel = {enableColumnMenus: false, enableFiltering: true, enableColumnResizing: false, enableRowSelection: false, enableSorting: true, enableRowHeaderSelection: false, rowHeight: 45};
	$scope.gridModel.columnDefs = [{name: 'Add/Edit Buttons', displayName:'', enableSorting: false, enableFiltering: false, width: 200, cellTemplate: '<button type="button" class="btn " ng-class="{ \'btn-warning\': row.entity.id, \'btn-success\': !row.entity.id }" ng-click="grid.appScope.AddOrShowUser(row.entity)">{{(row.entity.id) ? "Edit User" : "Add User to I-CART"}}</button>'},
	                               {field: 'first_name'},
	                               {field: 'last_name'},
	                               {field: 'email'},
	                               {field: 'ldap_uid'}];
	
	$scope.search = function(){  
	   // limit the user to one search request at at time
	   $scope.search_in_progress = true;
       $scope.searchResults = Identity.search({term: $scope.search_term}, function() {
    	 // reset the alert message
    	 $scope.alertMessage = "";
	     $scope.gridModel.data = $scope.searchResults;
	     $scope.search_in_progress = false;
	     $scope.resourceSuccessful = true;
	   }, function errorCallback(error) { 
    	 $scope.alertMessage = error.statusText;
    	 $scope.resourceSuccessful = false;
    	 $scope.search_in_progress = false;
       });
  	}; 
	
  	$scope.AddOrShowUser = function(identity) {
  		if (identity.id){
  			// display the user's info for editing
  			
  		} else {
  			// create the user in the database, grid automatically gets updated via object reference
  			identity.$save(function() {
  	  			$scope.alertMessage = identity.first_name +" " + identity.last_name + " has been added.";
  	  	        $scope.resourceSuccessful = true;
  	  		}, function errorCallback(error) { 
  	  			$scope.resourceSuccessful = false;
  	  	        $scope.alertMessage = error.statusText;
  	  	    });
  		}
  	};
 
	   
//	$scope.saveFormResponse = function(){
//		// convert the form response from an object to a string
//		$scope.currentLineItemAD.form_data_json = JSON.stringify($scope.currentLineItemAD.form_data_hash);
//		$scope.currentLineItemAD.$update(function(response) { 
//			// reload the Service Request and the grid
//			$scope.serviceRequest = ServiceRequest.get( function() {
//			   $scope.gridModel.data = $scope.serviceRequest.get_or_create_line_item_additional_details;
//			});
//			$scope.alertMessage = "Response saved.";
//			$scope.resourceSuccessful = true;
//  	     }, function errorCallback(error) { 
//  	    	$scope.alertMessage = error.statusText;
//	        $scope.resourceSuccessful = false;
//	     });
//	};
	
}]);

angular.module('app').controller('AdditionalDetailsDisplayController', ['$scope', 'Service', 'AdditionalDetail', 'LineItemAdditionalDetail', 'uiGridConstants', 'uiGridExporterConstants', '$controller', function($scope, Service, AdditionalDetail, LineItemAdditionalDetail, uiGridConstants, uiGridExporterConstants, $controller) {

	$scope.gridModel = {enableColumnMenus: false, enableFiltering: true, enableRowSelection: false, enableSorting: true, enableRowHeaderSelection: false, rowHeight: 45};
	$scope.gridModel.columnDefs = [
	                               {enableFiltering: false, enableColumnResizing: false, width: 215,  name: 'Additional Detail Form',  cellTemplate: '<a class="btn btn-primary" href="/additional_detail/services/'+service_id+'/additional_details/{{row.entity.id}}/duplicate">Duplicate</a> <a class="btn btn-primary" ng-if="row.entity.line_item_additional_details.length == 0" href="/additional_detail/services/'+service_id+'/additional_details/{{row.entity.id}}/edit">Edit</a> <button class="btn btn-danger" ng-if="row.entity.line_item_additional_details.length == 0" ng-click="grid.appScope.deleteAdditonalDetail(row.entity)">Delete</button>'},
	                               {enableFiltering: false, enableColumnResizing: false, width: 130, name: "Responses",  cellTemplate: '<button class="btn btn-info" ng-disabled="row.entity.line_item_additional_details.length==0" ng-click="grid.appScope.updateLineItemAdditionalDetails(row.entity.id)">Responses <span class="badge">{{row.entity.line_item_additional_details.length}}</span></button>'},
	                               {field: 'name', name: 'Name', width: '25%'}, 
	                               {field:'effective_date',name: 'Effective Date', width: '15%',  sort: { direction: uiGridConstants.DESC, priority: 1 } },
	                               {field: 'enabled',name: 'Enabled', cellTemplate: '<label>Enabled <input type="checkbox" ng-change="grid.appScope.updateAdditionalDetail(row.entity)" ng-model="row.entity.enabled"/></label>'},
	                               {field: 'description', name: 'Description'}
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