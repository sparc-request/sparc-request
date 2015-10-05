//= require additional_detail/jquery.min
//= require additional_detail/bootstrap.min
//= require additional_detail/bootstrap-datepicker.min
//= require additional_detail/validator
//= require additional_detail/angular.min
//= require additional_detail/angular-aria.min
//= require additional_detail/ui-grid.min
//= require additional_detail/angular-sanitize.min
//= require additional_detail/tv4
//= require additional_detail/ObjectPath
//= require additional_detail/schema-form.min
//= require additional_detail/bootstrap-decorator.min
//= require additional_detail/schema-form-date-time-picker.min
//= require additional_detail/angular-strap.min
//= require additional_detail/angular-strap-tpl.min
//= require additional_detail/angular-schema-form-dynamic-select.min
var typeHash;
var app = angular.module('app', ['ngAria','schemaForm','ui.grid','ui.grid.resizeColumns', 'mgcrea.ngStrap', 'schemaForm-datepicker', 'schemaForm-timepicker', 'schemaForm-datetimepicker','ui.grid.selection','ngSanitize', 'ui.grid.autoResize','ui.grid.expandable', 'ui.grid.edit']);

$('#myModal').on('shown.bs.modal', function () {
	$('#myInput').focus()
});

app.config([
     "$httpProvider", function($httpProvider) {
     $httpProvider.defaults.headers.common["Accept"] = "application/json";
     $httpProvider.defaults.headers.common["Content-Type"] = "application/json";
     $httpProvider.defaults.headers.common['X-CSRF-Token'] = $('meta[name=csrf-token]').attr('content');
     }]);

app.controller('AdditionalDetailsRootController', ['$scope', '$http', function($scope, $http) { 
	$scope.gridModel = {enableFiltering: true, enableColumnResizing: true, showColumnFooter: true , enableSorting: false, showGridFooter: true, enableRowHeaderSelection: false, rowHeight: 42};
	$scope.gridModel.columnDefs = [{field: 'service.name', name: 'Name',  width: '30%', enableColumnMenu: false ,}
	                               ];
	
}]);

app.controller("DocumentManagementAdditionalDetailsController", ['$scope', '$http', function($scope, $http) { 
	$scope.gridModel = {enableFiltering: true, enableColumnResizing: true, showColumnFooter: true , enableSorting: false, showGridFooter: true, enableRowHeaderSelection: false, rowHeight: 42, enableCellEdit:false};

	$scope.gridModel.columnDefs = [{enableFiltering: false, enableColumnResizing: false,name: 'Survey',width: 105, enableColumnMenu: false, cellTemplate: '<button data-toggle="modal" type="button" data-target="#myModal" class="btn btn-primary" ng-click="grid.appScope.showSurvey(row.entity.line_item_additional_detail.id)">{{(row.entity.line_item_additional_detail.form_data_json==null) ? "Take Survey" : "Edit Survey"}}</button>'},
	                               {field: 'line_item_additional_detail.line_item.service.name', name: 'Service', enableColumnMenu: false ,}, 
	                               {field:'status', width: '20%', enableColumnMenu: false }
	                               ];

	$scope.reloadGrid = function(){
		$http.get('/additional_detail/service_requests/'+id+'').
			then(function(response){
				$scope.gridModel.data = response.data;
				data = $scope.gridModel.data
				for(var i=0; i<data.length; i++){
					var required = JSON.parse(data[i].line_item_additional_detail.additional_detail.form_definition_json).schema.required;
					var model = JSON.parse(data[i].line_item_additional_detail.form_data_json);
					data[i].status = (allPresent(model, required)==false) ? "Incomplete" : "Complete"
				}
			});
	}
	
	function allPresent(model, required){
		for(var i=0; i<required.length; i++){
			if(!(required[i] in model)){return false;}
		}
		return true;
	}
	
	
	$scope.showSurvey = function(id){
		$scope.currentLineItemAD = $scope.getLineItemAdditionalDetail(id);
		if($scope.currentLineItemAD){
			var liad = $scope.currentLineItemAD;
			$scope.modal_title = liad.line_item.service.name;
			var object = JSON.parse(liad.additional_detail.form_definition_json);
			$scope.schema = object.schema;
			$scope.form   = object.form;		
			$scope.model = (liad.form_data_json==null) ? {} : JSON.parse(liad.form_data_json);
		}
		
	}
	
	$scope.getLineItemAdditionalDetail = function(id){
		var data = $scope.gridModel.data;
		for(var i=0; i< data.length; i++){
			if(data[i].line_item_additional_detail.id==id){
				return data[i].line_item_additional_detail;
			}
		}
		return null;
		
	}
	
	
	$scope.saveFormResponse = function(){
		var liad = $scope.currentLineItemAD;
		liad.form_data_json = JSON.stringify($scope.model);
		$http.put("/additional_detail/line_item_additional_details/"+liad.id, JSON.stringify(liad)).
			then(function(response){
				$scope.reloadGrid();
		});
	}
		
	$scope.reloadGrid();
	
}]);


app.controller('AdditionalDetailsDisplayController', ['$scope', '$http', function($scope, $http) {
	$scope.gridModel = {enableFiltering: true, enableColumnResizing: true, showColumnFooter: true , enableSorting: false, showGridFooter: true, enableRowHeaderSelection: false, rowHeight: 42};
	$scope.gridModel.columnDefs = [{enableFiltering: false, enableColumnResizing: false,name: 'Edit',width: 55, enableColumnMenu: false, cellTemplate: '<a class="btn btn-primary" role="button" ng-href="/additional_detail/services/'+id+'/additional_details/{{row.entity.additional_detail.id}}/edit">Edit</a>'},
	                               {field: 'additional_detail.name', name: 'Name',  width: '30%', enableColumnMenu: false ,}, 
	                               {field:'additional_detail.effective_date',name: 'Effective Date', width: '25%', enableColumnMenu: false },{field: 'additional_detail.approved',name: 'Approved', width: '10%', enableColumnMenu: false},
	                               {field: 'additional_detail.description', name: 'Description', enableColumnMenu: false},
	                               {enableFiltering: false, enableColumnResizing: false,name: 'Delete',width: 70, enableColumnMenu: false, cellTemplate: '<button class="btn btn-primary" ng-click="grid.appScope.deleteAdditonalDetail(row.entity.additional_detail.id)">Delete</button>'}
	                               ];
	
	$scope.reloadGrid = function(){
		$http.get('/additional_detail/services/'+id+'/additional_details/').
			then(function(response){
				$scope.gridModel.data = response.data;
			});
	}
	  
	$scope.reloadGrid();
	
	$scope.deleteAdditonalDetail = function(additonalDetailId){
		$http.delete('/additional_detail/services/'+id+'/additional_details/'+additonalDetailId).
			then(function(response){
				$scope.reloadGrid();
			}, function(response) {
				console.log(response);
			  });
		
	}
	
}]);

app.controller('FormCreationController', ['$scope', '$http', function ($scope, $http, $compile) {
		
	//var form_definition =  ;
 
	//$scope.formDefinition = $('#additional_detail_form_definition_json').val()
	$scope.form ={};
	$scope.effective_date = effective_date;

	$scope.typeHash = {
	    text: 'Text',
	    textarea : 'Text Area',
	    radiobuttons: 'Radiobuttons',
	    checkbox: 'Checkbox',
	    checkboxes: 'Checkboxes',
	    yesNo: 'Yes/No',
	    email: 'Email',
	    datepicker : 'Date',
	    number: 'Number',
	    zipcode : 'Zipcode',
	    state : 'State',
	    country : "Country",
	    time : "Time",
	    phone : "Phone",
	    dropdown : "Dropdown",
	    multiDropdown : "Multiple Dropdown"
	  };
	  
	typeHash = $scope.typeHash;	  
	$scope.typeHashKeyList = Object.keys($scope.typeHash);

	$scope.invaildDate = new Date((new Date()-86400000));

    $scope.formDefinition = ($('#additional_detail_form_definition_json').val() != "") ? $('#additional_detail_form_definition_json').val() : JSON.stringify({ schema: { type: "object",title: "Comment", properties: {},required: []}, form: []},undefined,2);
    
	 var dropdownKindList = ["multiDropdown", "dropdown", "state", "country"];
	 function generateGridArray(schema, form){
		 var gridArray = [];
		 for (var x=0; x < form.length; x++){
	     	var field = { name: "", key: form[x].key, kind: (form[x].kind != null) ? form[x].kind : form[x].type, values: "", required : inList(schema.required, form[x].key) };
	     	if (schema.properties[field.key]){
	     		var row = schema.properties[field.key];
	     		field.name = row.title;
				field.description = row.description;
				
			}
	     	if(inList(dropdownKindList, field.kind)=="true"){
	     		field.values = enumDisplay(form[x]);
	     	}
	     	else if(schema.properties[field.key]){
				var row = schema.properties[field.key];
				row.kind = field.kind;
				field.values = enumDisplay(row);	
	     	}
	     	if(field.key && field.key.length==1){field.key= field.key[0];}
	     	gridArray.push(field);
		  }
		 
		 return gridArray;
	 }
	
	 function enumDisplay(row){
		if(row.kind == "text" || row.kind=="textarea"){
			if(row.minLength && !row.maxLength){return row.minLength;}
			else if(!row.minLength && row.maxLength){return "0,"+row.maxLength;}
			else if(row.minLength && row.maxLength){return row.minLength +","+ row.maxLength;}
			return '';
		}
		else if(row.kind == "number"){
			if(row.minimum && !row.maximum){return row.minimum;}
			else if(!row.minimum && row.maximum){return "0,"+row.maximum;}
			else if(row.minimum && row.maximum){return row.minimum +","+ row.maximum;}
			return '';
		}
		else if(inList(dropdownKindList,row.kind)=="true"){
			var list = "";
			for(var i=0; i<row.titleMap.length-1; i++){
				list = list+row.titleMap[i].value+",";
			}
			list = list+row.titleMap[row.titleMap.length-1].value;
			return list;
			
		}
		else{
			var list = (row.items && row.items["enum"]) ? row.items["enum"] : row["enum"];			
			if(list){
				var s = "";
				for(var i=0; i<list.length-1; i++){
					s = s+list[i]+","
					}
				return s+list[list.length-1];
			}
			return '';
		}
	 }
	 
	 function inList(list, item){
		 for(var i=0; i<list.length; i++){
			 if(list[i]== item){return 'true';}
		 }
		 return 'false';
	 }
	  	 
 	 $scope.$watch('formDefinition',function(val){
 		 if (val) {
		    	object = JSON.parse(val);
		    	$scope.schema = object.schema;
		        $scope.form   = object.form;
		        $scope.gridModel.data = generateGridArray($scope.schema, $scope.form);
 		 }
 		 
		  }); 
 	
 	 $scope.pretty = function(){
		    return JSON.stringify($scope.model,undefined,2,2);
		  };
 		  
	// form def management
	  // default type to text for new fields
	  $scope.field = {};
	  // select list options
	  
	 $scope.displayValue; $scope.minMaxDisplay;
	 $scope.$watch('field.kind', function(val){
		 if(val =="radiobuttons" || val == "checkboxes" || val=="dropdown" || val=="multiDropdown"){
			$scope.displayValue = "";
		}
		else{$scope.displayValue = "display : none";}
		
		if(val=="text" || val== "textarea"){
			$scope.minMaxDisplay = "";
			$scope.minDisplay = "Minimum Length"
			$scope.maxDisplay = "Maximum Length"
		}
		else if(val=="number"){		
			$scope.minMaxDisplay = "";
			$scope.minDisplay = "Minimum Value"
			$scope.maxDisplay = "Maximum Value"
		}
		else{$scope.minMaxDisplay = "display : none";}
	 });
	  
	  function getKindHashArray(){
		  var hashArray =[];
		  var typeList  = Object.keys($scope.typeHash)
		  for(var i=0; i<typeList.length; i++){
			  var hash = {
					 id: typeList[i],
					 kind : $scope.typeHash[typeList[i]]
			  };
			  hashArray.push(hash);
		  }
		  return hashArray;
	  }
	    
	 
	  $scope.formKeySet = function(){
		  return Objects.keys($scope.model.form);
	  };
	  
	// for use by expandable rows in grid
		// $scope.$scope = $scope;
	  
	 // var upButton = '<button class="btn btn-primary glyphicon
		// glyphicon-chevron-up" ng-click="up({{row.entity.key}})"></button>';
	  // var $downButton = '<button class="btn btn-primary glyphicon
		// glyphicon-chevron-down"
		// ng-click="down({{row.entity.key}})"></button>'
	  	  
	  $scope.gridModel = {enableFiltering: true, enableColumnResizing: true, showColumnFooter: true , enableSorting: false, showGridFooter: true, enableRowHeaderSelection: false, rowHeight: 42};
	  $scope.gridModel.columnDefs = [
	                                 {name: 'question', field: 'name',  width: '21%', enableColumnMenu: false }, { name: 'key', width: '7%', enableColumnMenu: false }, 
	                                 { name: 'type', field: "kind", width: '15%',editableCellTemplate: 'ui-grid/dropdownEditor', cellFilter: 'mapKind', editDropdownValueLabel: 'kind', editDropdownOptionsArray: getKindHashArray(), enableColumnMenu: false},
	                               	 {field: 'values', name : "Values/Range", width: '13%', enableColumnMenu: false }, {name: 'required', width :'12%' ,editableCellTemplate: 'ui-grid/dropdownEditor',cellFilter: 'mapBoolean', editDropdownValueLabel: 'required', editDropdownOptionsArray: [
	                               	 {id: 'true', required: 'Yes' },{ id: 'false', required: 'No' }], enableColumnMenu: false},{field: "description", enableColumnMenu: false},
	                               	 {enableFiltering: false, enableCellEdit: false,enableColumnResizing: false,name:'Order', field :'up', width: 83,cellTemplate: '<button class="btn btn-primary glyphicon glyphicon-chevron-up" ng-click="grid.appScope.up(row.entity.key)"></button><button class="btn btn-primary glyphicon glyphicon-chevron-down" ng-click="grid.appScope.down(row.entity.key)"></button>', enableColumnMenu: false}
 	                                 ];

		function removeSpecial(value){
			if(value){
				return value.replace(/[^\w\s]/gi, '');
			}
			return '';
		}

		$scope.up= function(key){move(key, true);}
		$scope.down= function(key){move(key, false);}
		
		function move(key, up){
			var formDef = JSON.parse($scope.formDefinition);
			var form = formDef.form;
			for(var i=0; i<form.length; i++){
				if(form[i].key==key){
					var row = form[i];
					if(up==true && i != 0){
						var rowReplased  = form[i-1];
						form[i-1] = row;
						form[i] = rowReplased;
					}
					else if(up==false && i+1 !=form.length){
						var rowReplased  = form[i+1];
						form[i+1] = row;
						form[i] = rowReplased;
					}
					$scope.formDefinition = JSON.stringify(formDef,undefined,2,2);
					break;
				}
			}
		}
		
		// update data inline
		$scope.gridModel.onRegisterApi = function(gridApi){
	        // set gridApi on scope
	        $scope.gridApi = gridApi;
	         gridApi.edit.on.afterCellEdit($scope,function(rowEntity, colDef, newValue, oldValue){
	        var formDef = JSON.parse($scope.formDefinition);
	        
	        // when the key get changed
	        if(!formDef.schema.properties[rowEntity.key] && formDef.schema.properties[oldValue]){
	        	rowEntity.key = removeSpecial(rowEntity.key); // removes
																// special
																// characters
	        	var newForm = formDef.schema.properties[oldValue];
	        	formDef.schema.properties[rowEntity.key] = newForm;
	        	$scope.model[rowEntity.key] = $scope.model[oldValue];
	        	delete $scope.model[oldValue];
	        	delete formDef.schema.properties[oldValue];
	        	for(var x=0; x < formDef.form.length; x++){
	        		if (formDef.form[x].key && formDef.form[x].key == oldValue){
	        			formDef.form[x].key = rowEntity.key;
	        			break;
	        		}
	        	}
		        // update required array
		        for(var x=0; x<formDef.schema.required.length; x++){
		        	if(oldValue==formDef.schema.required[x]){
		        		formDef.schema.required.splice(x,1);
		        		formDef.schema.required.push(rowEntity.key);
		        		break;
		        	}
		        }	
	        }
	        
	        // when type is changed erase current value of key in model
	        if(typeHash[oldValue] && formDef.schema.properties[rowEntity.key]){
	        	delete $scope.model[rowEntity.key];
	        }
	        
	        // add into required if it is not there
	        if(rowEntity.required =='true' && inList(formDef.schema.required, rowEntity.key)=="false"){formDef.schema.required.push(rowEntity.key);}
	        else if(rowEntity.required =='false' && inList(formDef.schema.required, rowEntity.key)=="true"){
	        	var index = formDef.schema.required.indexOf(rowEntity.key);
	        	if(index > -1) {formDef.schema.required.splice(index, 1);}
	        }
        	formDef.schema.properties[rowEntity.key] = $scope.getSchema(rowEntity);
        	
        	for(var x=0; x<formDef.form.length; x++){
        		if(formDef.form[x].key==rowEntity.key){
        			formDef.form[x] = $scope.getForm(rowEntity);
        			break;
        		}
        	}      	
	   		$scope.formDefinition = JSON.stringify(formDef,undefined,2,2);
	   		$scope.gridModel.data = generateGridArray($scope.schema, $scope.form); 
	   		delete $scope.model[rowEntity.key];
	         })
	        	  
	      }
	    // delete selected rows
	    Array.prototype.removeByFormKey = function(val) {
		    for(var i=0; i<this.length; i++) {
		        if(this[i].key == val) {
		            this.splice(i, 1);
		            break;
		        }
		    }
		}
	    $scope.deleteSelected = function() {
		    var rows = $scope.gridApi.selection.getSelectedRows($scope.gridModel);
	    	var formDef = JSON.parse($scope.formDefinition)
		    for (var x=0;x<rows.length;x++) {
		    	if (formDef.schema.properties[rows[x].key]){
		    		delete formDef.schema.properties[rows[x].key];
		    		formDef.form.removeByFormKey([rows[x].key]);
		    	}
		    	// update schema/form definitions
	   			$scope.formDefinition = JSON.stringify(formDef,undefined,2,2);
	   			$scope.gridModel.data = generateGridArray($scope.schema, $scope.form); 
		  	}
	  	};   	
	  
	  	$scope.keyError = "Please fill out this field. Valid characters are A-Z a-z 0-9";
	  	
      $scope.add = function(f) {
    	  // prevent duplicates
    	 var field = hashCopy(f);
		 if(field.key && field.name && field.kind){
			  var formDef = JSON.parse($scope.formDefinition)
			  if (formDef.schema.properties[field.key]){
				  $scope.keyError = "Key already exists.";
				  f.key = "";
			  } else {
				 
				  $scope.keyError ="Please fill out this field. Valid characters are A-Z a-z 0-9";
				  if(field.description== null && (field.kind=="time" || field.kind=="datepicker")){
					  field.description = (field.kind=="time") ? "ex. 12:00 AM" : "ex. 06/13/2015";
				  }
 			  // add field form array
			  formDef.form.push ($scope.getForm(field));
			  // add field to schema
			  formDef.schema.properties[field.key] =  $scope.getSchema(field);
				  
			if(field.required ==true){formDef.schema.required.push(field.key);}
				  
			  $scope.formDefinition = JSON.stringify(formDef,undefined,2,2);
			  }
			  
			  // update schema/form definitions
			}
	 };	 
	 
	 function hashCopy(hash){
		 var newHash={};
		 var keyList = Object.keys(hash);
		 for(var i=0;i<keyList.length;i++){
			 newHash[keyList[i]] = hash[keyList[i]];
		 }
		 return newHash;
	 }
	 
	 $scope.clear = function(field){
		 field = {};
	 }
	 
	 var radioButtonStyle = {'selected': 'btn-success',  'unselected': 'btn-default'};
	 var radioDefaultValues = ["1","2","3","4","5","6","7","8","9","10"]; 
	 $scope.getForm = function(field){
		 field.key = removeSpecial(field.key); // removes special characters
		 var hash = {key: field.key, kind : field.kind, style: radioButtonStyle};
		 
		 if(field.kind == "yesNo"){
			 hash.type = "radiobuttons"; hash.titleMap= [{"value": "y","name": "Yes"},{"value": "n","name": "No"}];
			 return hash; 
		 }
		 if(field.kind == "state"){
			 hash.placeholder="Select One"; hash.type = "strapselect";
			 hash.titleMap = [{'value' : 'AL','name' : 'Alabama'},{'value' : 'AK','name' : 'Alaska'},{'value' : 'AZ','name' : 'Arizona'},{'value' : 'AR','name' : 'Arkansas'},
                              {'value' : 'CA','name' : 'California'},{'value' : 'CO','name' : 'Colorado'},{'value' : 'CT','name' : 'Connecticut'},{'value' : 'DE','name' : 'Delaware'},
                              {'value' : 'DC','name' : 'District of Columbia'},{'value' : 'FL','name' : 'Florida'},{'value' : 'GA','name' : 'Georgia'},{'value' : 'HI','name' : 'Hawaii'},
                              {'value' : 'ID','name' : 'Idaho'},{'value' : 'IL','name' : 'Illinois'},{'value' : 'IN','name' : 'Indiana'},{'value' : 'IA','name' : 'Iowa'},
                              {'value' : 'KS','name' : 'Kansas'},{'value' : 'KY','name' : 'Kentucky'},{'value' : 'LA','name' : 'Louisiana'},{'value' : 'ME','name' : 'Maine'},
                              {'value' : 'MT','name' : 'Montana'},{'value' : 'NE','name' : 'Nebraska'},{'value' : 'NV','name' : 'Nevada'},{'value' : 'NH','name' : 'New Hampshire'},
                              {'value' : 'NJ','name' : 'New Jersey'},{'value' : 'NM','name' : 'New Mexico'},{'value' : 'NY','name' : 'New York'},{'value' : 'NC','name' : 'North Carolina'},
                              {'value' : 'ND','name' : 'North Dakota'},{'value' : 'OH','name' : 'Ohio'},{'value' : 'OK','name' : 'Oklahoma'},{'value' : 'OR','name' : 'Oregon'},
                              {'value' : 'MD','name' : 'Maryland'},{'value' : 'MA','name' : 'Massachusetts'},{'value' : 'MI','name' : 'Michigan'},{'value' : 'MN','name' : 'Minnesota'},
                              {'value' : 'MS','name' : 'Mississippi'},{'value' : 'MO','name' : 'Missouri'},{'value' : 'PA','name' : 'Pennsylvania'},{'value' : 'RI','name' : 'Rhode Island'},
                              {'value' : 'SC','name' : 'South Carolina'},{'value' : 'SD','name' : 'South Dakota'},{'value' : 'TN','name' : 'Tennessee'},{'value' : 'TX','name' : 'Texas'},
                              {'value' : 'UT','name' : 'Utah'},{'value' : 'VT','name' : 'Vermont'},{'value' : 'VA','name' : 'Virginia'},{'value' : 'WA','name' : 'Washington'},{'value' : 'WV','name' : 'West Virginia'},
                              {'value' : 'WI','name' : 'Wisconsin'},{'value' : 'WY','name' : 'Wyoming'}];
			 return hash;
		 }
		 
		 else if(field.kind == 'country'){
			 hash.placeholder="Select One";
			 hash.type = "strapselect";
			 hash.titleMap = [{ "value" : "US", "name" : "United States"},{ "value" : 'AD', "name" : 'Andorra'},{ "value" : 'AE', "name" : 'United Arab Emirates'},{ "value" : 'AF', "name" : 'Afghanistan'},{ "value" : 'AG', "name" : 'Antigua and Barbuda'},
			                  { "value" : 'AI', "name" : 'Anguilla'},{ "value" : 'AL', "name" : 'Albania'},{ "value" : 'AM', "name" : 'Armenia'},{ "value" : 'AO', "name" : 'Angola'},
			                  { "value" : 'AQ', "name" : 'Antarctica'},{ "value" : 'AR', "name" : 'Argentina'},{ "value" : 'AS', "name" : 'American Samoa'},{ "value" : 'AT', "name" : 'Austria'},
			                  { "value" : 'AU', "name" : 'Australia'},{ "value" : 'AW', "name" : 'Aruba'},{ "value" : 'AX', "name" : 'Âland Islands'},{ "value" : 'AZ', "name" : 'Azerbaijan'},
			                  { "value" : 'BA', "name" : 'Bosnia and Herzegovina'},{ "value" : 'BB', "name" : 'Barbados'},{ "value" : 'BD', "name" : 'Bangladesh'},{ "value" : 'BE', "name" : 'Belgium'},
			                  { "value" : 'BF', "name" : 'Burkina Faso'},{ "value" : 'BG', "name" : 'Bulgaria'},{ "value" : 'BH', "name" : 'Bahrain'},{ "value" : 'BI', "name" : 'Burundi'},
			                  { "value" : 'BJ', "name" : 'Benin'},{ "value" : 'BL', "name" : 'Saint BarthÅ½lemy'},{ "value" : 'BM', "name" : 'Bermuda'},{ "value" : 'BN', "name" : 'Brunei Darussalam'},
			                  { "value" : 'BO', "name" : 'Bolivia'},{ "value" : 'BQ', "name" : 'Caribbean Netherlands '},{ "value" : 'BR', "name" : 'Brazil'},{ "value" : 'BS', "name" : 'Bahamas'},
			                  { "value" : 'BT', "name" : 'Bhutan'},{ "value" : 'BV', "name" : 'Bouvet Island'},{ "value" : 'BW', "name" : 'Botswana'},{ "value" : 'BY', "name" : 'Belarus'},{ "value" : 'BZ', "name" : 'Belize'},
			                  { "value" : 'CA', "name" : 'Canada'},{ "value" : 'CC', "name" : 'Cocos (Keeling) Islands'},{ "value" : 'CD', "name" : 'Congo, Democratic Republic of'},{ "value" : 'CF', "name" : 'Central African Republic'},
			                  { "value" : 'CG', "name" : 'Congo'},{ "value" : 'CH', "name" : 'Switzerland'},{ "value" : 'CI', "name" : "Cote d'Ivoire"},{ "value" : 'CK', "name" : 'Cook Islands'},{ "value" : 'CL', "name" : 'Chile'},
			                  { "value" : 'CM', "name" : 'Cameroon'},{ "value" : 'CN', "name" : 'China'},{ "value" : 'CO', "name" : 'Colombia'},{ "value" : 'CR', "name" : 'Costa Rica'},{ "value" : 'CU', "name" : 'Cuba'},
			                  { "value" : 'CV', "name" : 'Cape Verde'},{ "value" : 'CW', "name" : 'CuraÂao'},{ "value" : 'CX', "name" : 'Christmas Island'},{ "value" : 'CY', "name" : 'Cyprus'},{ "value" : 'CZ', "name" : 'Czech Republic'},
			                  { "value" : 'DE', "name" : 'Germany'},{ "value" : 'DJ', "name" : 'Djibouti'},{ "value" : 'DK', "name" : 'Denmark'},{ "value" : 'DM', "name" : 'Dominica'},{ "value" : 'DO', "name" : 'Dominican Republic'},
			                  { "value" : 'DZ', "name" : 'Algeria'},{ "value" : 'EC', "name" : 'Ecuador'},{ "value" : 'EE', "name" : 'Estonia'},{ "value" : 'EG', "name" : 'Egypt'},{ "value" : 'EH', "name" : 'Western Sahara'},
			                  { "value" : 'ER', "name" : 'Eritrea'},{ "value" : 'ES', "name" : 'Spain'},{ "value" : 'ET', "name" : 'Ethiopia'},{ "value" : 'FI', "name" : 'Finland'},{ "value" : 'FJ', "name" : 'Fiji'},
			                  { "value" : 'FK', "name" : 'Falkland Islands'},{ "value" : 'FM', "name" : 'Micronesia, Federated States of'},{ "value" : 'FO', "name" : 'Faroe Islands'},{ "value" : 'FR', "name" : 'France'},
			                  { "value" : 'GA', "name" : 'Gabon'},{ "value" : 'GB', "name" : 'United Kingdom'},{ "value" : 'GD', "name" : 'Grenada'},{ "value" : 'GE', "name" : 'Georgia'},{ "value" : 'GF', "name" : 'French Guiana'},
			                  { "value" : 'GG', "name" : 'Guernsey'},{ "value" : 'GH', "name" : 'Ghana'},{ "value" : 'GI', "name" : 'Gibraltar'},{ "value" : 'GL', "name" : 'Greenland'},{ "value" : 'GM', "name" : 'Gambia'},
			                  { "value" : 'GN', "name" : 'Guinea'},{ "value" : 'GP', "name" : 'Guadeloupe'},{ "value" : 'GQ', "name" : 'Equatorial Guinea'},{ "value" : 'GR', "name" : 'Greece'},{ "value" : 'GS', "name" : 'South Georgia and the South Sandwich Islands'},
			                  { "value" : 'GT', "name" : 'Guatemala'},{ "value" : 'GU', "name" : 'Guam'},{ "value" : 'GW', "name" : 'Guinea-Bissau'},{ "value" : 'GY', "name" : 'Guyana'},{ "value" : 'HK', "name" : 'Hong Kong'},
			                  { "value" : 'HM', "name" : 'Heard and McDonald Islands'},{ "value" : 'HN', "name" : 'Honduras'},{ "value" : 'HR', "name" : 'Croatia'},{ "value" : 'HT', "name" : 'Haiti'},{ "value" : 'HU', "name" : 'Hungary'},{ "value" : 'ID', "name" : 'Indonesia'},
			                  { "value" : 'IE', "name" : 'Ireland'},{ "value" : 'IL', "name" : 'Israel'},{ "value" : 'IM', "name" : 'Isle of Man'},{ "value" : 'IN', "name" : 'India'},{ "value" : 'IO', "name" : 'British Indian Ocean Territory'},{ "value" : 'IQ', "name" : 'Iraq'},
			                  { "value" : 'IR', "name" : 'Iran'},{ "value" : 'IS', "name" : 'Iceland'},{ "value" : 'IT', "name" : 'Italy'},{ "value" : 'JE', "name" : 'Jersey'},{ "value" : 'JM', "name" : 'Jamaica'},{ "value" : 'JO', "name" : 'Jordan'},
			                  { "value" : 'JP', "name" : 'Japan'},{ "value" : 'KE', "name" : 'Kenya'},{ "value" : 'KG', "name" : 'Kyrgyzstan'},{ "value" : 'KH', "name" : 'Cambodia'},{ "value" : 'KI', "name" : 'Kiribati'},
			                  { "value" : 'KM', "name" : 'Comoros'},{ "value" : 'KN', "name" : 'Saint Kitts and Nevis'},{ "value" : 'KP', "name" : 'North Korea'},{ "value" : 'KR', "name" : 'South Korea'},{ "value" : 'KW', "name" : 'Kuwait'},
			                  { "value" : 'KY', "name" : 'Cayman Islands'},{ "value" : 'KZ', "name" : 'Kazakhstan'},{ "value" : 'LA', "name" : "Lao People's Democratic Republic"},{ "value" : 'LB', "name" : 'Lebanon'},{ "value" : 'LC', "name" : 'Saint Lucia'},
			                  { "value" : 'LI', "name" : 'Liechtenstein'},{ "value" : 'LK', "name" : 'Sri Lanka'},{ "value" : 'LR', "name" : 'Liberia'},{ "value" : 'LS', "name" : 'Lesotho'},{ "value" : 'LT', "name" : 'Lithuania'},
			                  { "value" : 'LU', "name" : 'Luxembourg'},{ "value" : 'LV', "name" : 'Latvia'},{ "value" : 'LY', "name" : 'Libya'},{ "value" : 'MA', "name" : 'Morocco'},{ "value" : 'MC', "name" : 'Monaco'},
			                  { "value" : 'MD', "name" : 'Moldova'},{ "value" : 'ME', "name" : 'Montenegro'},{ "value" : 'MF', "name" : 'Saint-Martin (France)'},{ "value" : 'MG', "name" : 'Madagascar'},
			                  { "value" : 'MH', "name" : 'Marshall Islands'},{ "value" : 'MK', "name" : 'Macedonia'},{ "value" : 'ML', "name" : 'Mali'},{ "value" : 'MM', "name" : 'Myanmar'},{ "value" : 'MN', "name" : 'Mongolia'},
			                  { "value" : 'MO', "name" : 'Macau'},{ "value" : 'MP', "name" : 'Northern Mariana Islands'},{ "value" : 'MQ', "name" : 'Martinique'},{ "value" : 'MR', "name" : 'Mauritania'},
			                  { "value" : 'MS', "name" : 'Montserrat'},{ "value" : 'MT', "name" : 'Malta'},{ "value" : 'MU', "name" : 'Mauritius'},{ "value" : 'MV', "name" : 'Maldives'},{ "value" : 'MW', "name" : 'Malawi'},
			                  { "value" : 'MX', "name" : 'Mexico'},{ "value" : 'MY', "name" : 'Malaysia'},{ "value" : 'MZ', "name" : 'Mozambique'},{ "value" : 'NA', "name" : 'Namibia'},{ "value" : 'NC', "name" : 'New Caledonia'},
			                  { "value" : 'NE', "name" : 'Niger'},{ "value" : 'NF', "name" : 'Norfolk Island'},{ "value" : 'NG', "name" : 'Nigeria'},{ "value" : 'NI', "name" : 'Nicaragua'},{ "value" : 'NL', "name" : 'The Netherlands'},
			                  { "value" : 'NO', "name" : 'Norway'},{ "value" : 'NP', "name" : 'Nepal'},{ "value" : 'NR', "name" : 'Nauru'},{ "value" : 'NU', "name" : 'Niue'},{ "value" : 'NZ', "name" : 'New Zealand'},
			                  { "value" : 'OM', "name" : 'Oman'},{ "value" : 'PA', "name" : 'Panama'},{ "value" : 'PE', "name" : 'Peru'},{ "value" : 'PF', "name" : 'French Polynesia'},{ "value" : 'PG', "name" : 'Papua New Guinea'},
			                  { "value" : 'PH', "name" : 'Philippines'},{ "value" : 'PK', "name" : 'Pakistan'},{ "value" : 'PL', "name" : 'Poland'},{ "value" : 'PM', "name" : 'St. Pierre and Miquelon'},
			                  { "value" : 'PN', "name" : 'Pitcairn'},{ "value" : 'PR', "name" : 'Puerto Rico'},{ "value" : 'PS', "name" : 'Palestine, State of'},{ "value" : 'PT', "name" : 'Portugal'},
			                  { "value" : 'PW', "name" : 'Palau'},{ "value" : 'PY', "name" : 'Paraguay'},{ "value" : 'QA', "name" : 'Qatar'},{ "value" : 'RE', "name" : 'RÅ½union'},
			                  { "value" : 'RO', "name" : 'Romania'},{ "value" : 'RS', "name" : 'Serbia'},{ "value" : 'RU', "name" : 'Russian Federation'},{ "value" : 'RW', "name" : 'Rwanda'},
			                  { "value" : 'SA', "name" : 'Saudi Arabia'},{ "value" : 'SB', "name" : 'Solomon Islands'},{ "value" : 'SC', "name" : 'Seychelles'},{ "value" : 'SD', "name" : 'Sudan'},
			                  { "value" : 'SE', "name" : 'Sweden'},{ "value" : 'SG', "name" : 'Singapore'},{ "value" : 'SH', "name" : 'Saint Helena'},{ "value" : 'SI', "name" : 'Slovenia'},
			                  { "value" : 'SJ', "name" : 'Svalbard and Jan Mayen Islands'},{ "value" : 'SK', "name" : 'Slovakia'},{ "value" : 'SL', "name" : 'Sierra Leone'},
			                  { "value" : 'SM', "name" : 'San Marino'},{ "value" : 'SN', "name" : 'Senegal'},{ "value" : 'SO', "name" : 'Somalia'},{ "value" : 'SR', "name" : 'Suriname'},
			                  { "value" : 'SS', "name" : 'South Sudan'},{ "value" : 'ST', "name" : 'Sao Tome and Principe'},{ "value" : 'SV', "name" : 'El Salvador'},
			                  { "value" : 'SX', "name" : 'Sint Maarten (Dutch part)'},{ "value" : 'SY', "name" : 'Syria'},{ "value" : 'SZ', "name" : 'Swaziland'},{ "value" : 'TC', "name" : 'Turks and Caicos Islands'},
			                  { "value" : 'TD', "name" : 'Chad'},{ "value" : 'TF', "name" : 'French Southern Territories'},{ "value" : 'TG', "name" : 'Togo'},{ "value" : 'TH', "name" : 'Thailand'},
			                  { "value" : 'TJ', "name" : 'Tajikistan'},{ "value" : 'TK', "name" : 'Tokelau'},{ "value" : 'TL', "name" : 'Timor-Leste'},{ "value" : 'TM', "name" : 'Turkmenistan'},
			                  { "value" : 'TN', "name" : 'Tunisia'},{ "value" : 'TO', "name" : 'Tonga'},{ "value" : 'TR', "name" : 'Turkey'},{ "value" : 'TT', "name" : 'Trinidad and Tobago'},
			                  { "value" : 'TV', "name" : 'Tuvalu'},{ "value" : 'TW', "name" : 'Taiwan'},{ "value" : 'TZ', "name" : 'Tanzania'},{ "value" : 'UA', "name" : 'Ukraine'},
			                  { "value" : 'UG', "name" : 'Uganda'},{ "value" : 'UM', "name" : 'United States Minor Outlying Islands'},{ "value" : 'UY', "name" : 'Uruguay'},
			                  { "value" : 'UZ', "name" : 'Uzbekistan'},{ "value" : 'VA', "name" : 'Vatican'},{ "value" : 'VC', "name" : 'Saint Vincent and the Grenadines'},{ "value" : 'VE', "name" : 'Venezuela'},
			                  { "value" : 'VG', "name" : 'Virgin Islands (British)'},{ "value" : 'VI', "name" : 'Virgin Islands (U.S.)'},{ "value" : 'VN', "name" : 'Vietnam'},{ "value" : 'VU', "name" : 'Vanuatu'},
			                  { "value" : 'WF', "name" : 'Wallis and Futuna Islands'},{ "value" : 'WS', "name" : 'Samoa'},{ "value" : 'YE', "name" : 'Yemen'},{ "value" : 'YT', "name" : 'Mayotte'},
			                  { "value" : 'ZA', "name" : 'South Africa'},{ "value" : 'ZM', "name" : 'Zambia'},{ "value" : 'ZW', "name" : 'Zimbabwe'}];
			 return hash;
		 } 
		 else if(field.kind == "email"){
			 hash.type = "string";
			 hash.placeholder ="ex. youremail@email.com";
			 return hash;
		 }
		 else if(field.kind == "file"){
			 hash.type = "string";
			 hash.format ="file-reader"
			 return hash;
		 }
		 else if(field.kind =="dropdown"){
			 hash.type = "strapselect";
			 var valueList = (field.values) ? cleanSplit(field.values) : radioDefaultValues;
			 hash.titleMap = getTileMap(valueList);  hash.placeholder="Select One";
			 return hash;
			 }
		 else if(field.kind == "phone"){
			 hash.type = "string";
			 hash.placeholder = "ex. 555-555-5555"
			 return hash;
		 }
		 else if(field.kind == "multiDropdown"){
			 hash.type = "strapselect";
			 var valueList = (field.values) ? cleanSplit(field.values) : radioDefaultValues;
			 hash.options = {multiple : true}; hash.placeholder ="Select One or More"
			 hash.titleMap = getTileMap(valueList);
			 return hash
		 }
		 else if(field.kind == "datepicker"){
			 hash.type = "datepicker";
			 hash.dateOptions = {
					 dateFormat : "MM/dd/yyyy" 
			 }
			 return hash;
		 }
		 else if(field.kind == "number"){
			 hash.type = "number";
			 return hash;
		 }
		 else if(field.kind == "time"){
			 hash.type = "timepicker";
			 hash.timeOptions= {
					title : field.title,
				    minuteStep: 1,
				  }
			 return hash;
		 }
		 else if(field.kind == "zipcode"){
			 hash.type = "string";
			 hash.placeholder = "ex. 55555 or 55555-5555"
			 return hash;
		 }
		 else if(field.kind == "checkboxes"){
			hash.type = field.kind;
			var valueList = (field.values) ? cleanSplit(field.values) : radioDefaultValues;
			hash.titleMap = getTileMap(valueList);
			return hash;
		 }
		 else if(field.kind == "radiobuttons"){
			 hash.type = field.kind;
			 var valueList = (field.values) ? cleanSplit(field.values) : radioDefaultValues;
			 hash.titleMap = getTileMap(valueList);	
			 return hash;
		 }
		 else{
			 hash.type =field.kind;
			 return hash;
		 }
	 }
	 
	 function cleanSplit(value){
		 var list = value.split(","); var cleanList=[];
		 for(var i=0; i<list.length; i++){
			 var e = list[i].trim();
			 if(e != ''){cleanList.push(e);}
		 }
		 return cleanList;
	 }
	 

	 function capitalizeFirstLetter(string) {
		    return string.charAt(0).toUpperCase() + string.slice(1);
		}
	 
	 function getTileMap(list){
		 var tileMap =[];
		 for(var i=0; i<list.length; i++){
			 var tile = {value : list[i], name : capitalizeFirstLetter(list[i])};
			 tileMap.push(tile);	 
		 }
		 return tileMap;
	 }
	 
	 function minMaxSwitch(hash){
		var maxType = (hash.maxLength) ? "maxLength" : "maximum";	 
		var minType= (hash.minLength) ? "minLength" : "minimum";
		 if(typeof hash[maxType] =="string"){hash[maxType] = parseInt(hash[maxType]);}
			if(typeof hash[minType] =="string"){hash[minType] = parseInt(hash[minType]);}
	 		if(hash[maxType] && hash[minType] && (hash[maxType]<hash[minType])){
	 			var newHash = hash[minType];
	 			hash[minType]= hash[maxType];
	 			hash[maxType]= newHash;
	 		}
	 	return hash;
	 }
	 
	 
	 $scope.getSchema = function(field){			 
		 field.key = removeSpecial(field.key); // removes special characters
		var hash = {title: field.name, description : field.description};
		
	 	 if(field.kind =="datepicker"){
	 		 hash.type = "string"; hash.format = "datepicker"; hash.validationMessage = "Please enter vaild date ex. 06/13/2015";
	 			return hash;
	 		}
	 	 else if(field.kind == "text" || field.kind == "textarea"){
	 		hash.type = "string";
	 		 if(field.min || field.values){hash.minLength =(field.values) ? cleanSplit(field.values)[0] : field.min;}
	 		if(field.max || (field.values && cleanSplit(field.values).length >1)){hash.maxLength =(field.values) ? cleanSplit(field.values)[1] : field.max;}
	 		 hash = minMaxSwitch(hash);
	 		return hash;
	 	 }
		 else if(field.kind == "yesNo"){
			 hash["enum"] = ["y","n"]; hash.type="string";
				return hash;
			}
		 else if(field.kind == "state"){
			 hash.type = "string";
			 return hash;
		 }
		 else if(field.kind == "country"){
			 hash.type = "string";
			 return hash;
		 }
		 else if(field.kind == "multiDropdown"){
			 hash.items = {"type": "string"}; 
			 hash.type = "array"; 
			 return hash;
		 }
		 else if(field.kind == "phone"){
				hash.type = "string"; hash.pattern = "^[0-9]{3}-[0-9]{3}-[0-9]{4}$"; hash.validationMessage = "Please enter vaild phone number.";
				return hash;
			}
		else if(field.kind == "radiobuttons"){
			 hash["enum"] = (field.values) ? cleanSplit(field.values)  : radioDefaultValues;
			 hash.type = "string"; 
			return hash;
		}
		else if(field.kind == "file"){
			hash.type = "string";
			return hash;
		}
		else if(field.kind == "dropdown"){
			 hash.type = "string";
			 return hash;
		}
	 	 
		else if(field.kind =="checkboxes"){
			hash.items = {"type": "string", "enum": (field.values) ? cleanSplit(field.values)  : radioDefaultValues};
			hash.type = "array";
			return hash;
		}
		else if(field.kind == "email"){
			hash.type = "string"; hash.pattern = "^\\S+@\\S+$"; hash.validationMessage = "Please enter vaild email.";
			return hash;
		}
		else if(field.kind == "zipcode"){
			hash.type = "string"; hash.pattern = "^[0-9]{5}(-[0-9]{4})?$"; hash.validationMessage = "Please enter vaild zip code.";
			return hash;
		}
		else if(field.kind == "time"){
			hash.validationMessage = "Please a vaild time ex. 12:00 AM"; hash.type = "string";
			hash.format = "timepicker";
			return hash;
		}
		else if(field.kind == "checkbox"){
			hash.type = "boolean";
			return hash;
		}
		else if(field.kind == "number"){
			if(field.min || (field.values && cleanSplit(field.values)[0])){
				hash.minimum = (field.min) ? field.min : cleanSplit(field.values)[0];
			}
			if(field.max || (field.values && cleanSplit(field.values)[1])){
	 			hash.maximum = (field.max) ? field.max : cleanSplit(field.values)[1];
			}
			hash = minMaxSwitch(hash);
			hash.type = "integer";
			return hash;
		}
		else{
			hash.type = "string";
			return hash;
		}
		
	 }
	 	      
  $scope.model = {};
  
}]).filter('mapKind', function() { 
  return function(input) {
    if (!input){
      return '';
    } else {
      return typeHash[input];
    }
  };
}).filter('mapBoolean', function() { 
  var hash = {
	"true" : "Yes",
	"false" : "No"
  }
	return function(input) {
					if (!input) {
						return '';
					} else {
						return hash[input];
					}
				};
			});		