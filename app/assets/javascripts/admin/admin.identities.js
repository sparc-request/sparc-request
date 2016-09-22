// Copyright © 2011-2016 MUSC Foundation for Research Development~
// All rights reserved.~

// Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

// 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

// 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
// disclaimer in the documentation and/or other materials provided with the distribution.~

// 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
// derived from this software without specific prior written permission.~

// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
// BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
// SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
// TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

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
	$scope.gridModel.columnDefs = [{name: 'Add/Edit Buttons', displayName:'', enableSorting: false, enableFiltering: false, width: 200, cellTemplate: '<button type="button" class="btn " ng-class="{ \'btn-warning\': row.entity.id, \'btn-success\': !row.entity.id }" ng-click="grid.appScope.AddOrShowUser(row.entity)">{{(row.entity.id) ? "' +I18n["admin_identities"]["button_edit_user"] +'" : "' +I18n["admin_identities"]["button_add_user"] +'"}}</button>'},
	                               {field: 'ldap_uid', displayName: I18n["admin_identities"]["grid_uid"]},
	                               {field: 'first_name'},
	                               {field: 'last_name'},
	                               {field: 'email'}
	                               ];
	
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
  			// hide the alert messages before showing a user
  			$scope.alertMessage = null;
  	    	$scope.alertMessageUpdate = null;
  			// We need to load the identity data from this controller because it authorizes the current user to view it.
  			Identity.get({ id: identity.id }).$promise.then(function(retrieved_identity) {
  				$scope.currentIdentity = retrieved_identity;
  				$('#identityModal').modal();
  			}, function errorCallback(error) { 
  		    	 $scope.alertMessage = error.statusText;
  		    	 $scope.resourceSuccessful = false;
  		    });
  		} else {
  			// create the user in the database, grid automatically gets updated via object reference
  			identity.$save(function() {
  			    // hide the update alert message
  	  		    $scope.alertMessageUpdate = null;
  	  			$scope.alertMessage = identity.first_name +" " + identity.last_name + " has been added. " + I18n["admin_identities"]["return_to_basic_user_search"];
  	  	        $scope.resourceSuccessful = true;
  	  		}, function errorCallback(error) { 
  	  		    $scope.alertMessage = error.statusText;
  	  		    // hide the update alert message
  	  		    $scope.alertMessageUpdate = null;
  	  			$scope.resourceSuccessful = false;
  	  	    });
  		}
  	};
 
  	$scope.updateUser = function(){
  		$scope.currentIdentity.$update(function(updated_identity) { 
  			$scope.alertMessageUpdate = updated_identity.first_name +" " + updated_identity.last_name + " has been updated.";
			$scope.resourceSuccessful = true;
			// refresh the grid
			$scope.search();
  	     }, function errorCallback(error) { 
  	    	$scope.alertMessageUpdate = error.statusText;
	        $scope.resourceSuccessful = false;
	     });
  	};	
}]);