angular.module('app').controller('FormCreationController', ['$scope', '$controller', function ($scope, $controller) {
	// extend the ConditionalQuestionsFormController to gain access to the conditional question functions
	// logic for conditional questions is not ready to be used because it needs fine tuning and testing 
	// angular.extend(this, $controller('ConditionalQuestionsFormController', {$scope: $scope}));
	// extend the QuestionsFormController to gain access to basic question functions
	angular.extend(this, $controller('QuestionsFormController', {$scope: $scope}));
	// Load the Additional Detail fields used by Angular from the server side values set in new.html.haml
	// this is not how Angular likes to operate but we needed to do it this way to be able to easily duplicate additional detail forms
	$scope.effective_date = $('#additional_detail_effective_date').val();
	$scope.form_definition_json = $('#additional_detail_form_definition_json').val();
    $scope.currentLineItemAD = { additional_detail_description: $('#additional_detail_description').val() }; 	
	
    $scope.gridModel = {enableColumnMenus: false, enableSorting: false, enableRowHeaderSelection: false, rowHeight: 45};
	$scope.gridModel.columnDefs = [{name: ' ', width: 53, cellTemplate: '<button type="button" class="btn btn-primary" ng-click="grid.appScope.editQuestion(row.entity.id)">Edit</button>' },
	                                 {name: 'question', field: 'name'},
	                                 {name: 'key', field: 'key'},
	                                 {name: 'type', field: "kind", width: '15%'},
	                               	 {name: 'required', width :'15%'},
	             // logic for conditional questions is not ready to be used because it needs fine tuning and testing                  	 
	             //                  	 {name: 'conditional', width: '15%'},
	                               	 {name:'Order', field :'up', width: 83, cellTemplate: '<button type="button" class="btn btn-primary glyphicon glyphicon-chevron-up" ng-click="grid.appScope.up(row.entity.key)"></button><button type="button" class="btn btn-primary glyphicon glyphicon-chevron-down" ng-click="grid.appScope.down(row.entity.key)"></button>'}
	                               	];
	// dynamically change grid height relative to the # of rows of data, 
	//   only works if one grid is being displayed on the page
  	$scope.getTableHeight = function() {
        return {
        	height: (($scope.gridModel.data.length * $scope.gridModel.rowHeight) + $( ".ui-grid-header-cell-row" ).height() )+18 + "px"
        };
     };
     
	$scope.gridModel.onRegisterApi = function(gridApi){
		$scope.gridApi = gridApi;
	};
    
    // this watch is called on page load, when the user imports a schema, and after $scope.updateFormDefinition
    $scope.$watch('form_definition_json',function(newValue, oldValue){  
      if (newValue){
        var parsedFormDefinitionJSON = $.parseJSON(newValue);
        $scope.currentLineItemAD.additional_detail_schema_hash = parsedFormDefinitionJSON.schema; 
        $scope.currentLineItemAD.additional_detail_form_array = parsedFormDefinitionJSON.form;
        // reset the preview's answers after a change to the schema
        $scope.currentLineItemAD.form_data_hash = {}; 	     
        // initialize or reload the grid
        var questions = [];
    	for (var x=0; x < $scope.currentLineItemAD.additional_detail_form_array.length; x++){
		  var q = $scope.getQuestion($scope.currentLineItemAD.additional_detail_form_array[x].id);
		  if(q != null){
		    questions.push(q);
		  }
	    }
 	    $scope.gridModel.data = questions;
      }
  	}); 
    // this triggers the $watch above and needs to be called any time the form schema or array has changed.
    $scope.updateFormDefinition = function(){
	  // something unexplained is happening, the form array's key values are being converted to a type of Array instead of staying as strings
  	  // loop through and convert Array keys to String keys
	  for(var x=0; x<$scope.currentLineItemAD.additional_detail_form_array.length; x++){
		if(Array.isArray($scope.currentLineItemAD.additional_detail_form_array[x].key)){
			$scope.currentLineItemAD.additional_detail_form_array[x].key = $scope.currentLineItemAD.additional_detail_form_array[x].key[0];
		}
		// another interesting issue, we get a "Converting circular structure to JSON" error
		// if we don't remove the scope key from the options value
		if($scope.currentLineItemAD.additional_detail_form_array[x].options && $scope.currentLineItemAD.additional_detail_form_array[x].options.scope){
		  delete $scope.currentLineItemAD.additional_detail_form_array[x].options.scope; 
		}
	  }
      $scope.form_definition_json = JSON.stringify({ schema: $scope.currentLineItemAD.additional_detail_schema_hash, 
            										 form:   $scope.currentLineItemAD.additional_detail_form_array }, undefined,2);     	
    }
     
	// Displays the form data that will be exported when a user answers the questions
	$scope.pretty = function(){
	  return JSON.stringify($scope.currentLineItemAD.form_data_hash,undefined,2,2);
	};
	
	// The list of question types
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
	
	// used to limit the additional detail's effective date date picker to a day of today or in the future
	$scope.datePickerMinDate = new Date() -86400000;
	    
    //Uses a key name to populate add/edit question model with question data, if key==null then a new question will be created
    $scope.resetQuestion = function(){
    	$scope.field = {};
    };
      
    $scope.editQuestion = function(id){
		// hide the alert message before showing new question
		$scope.alertMessage = null;
    	//find key if it exists
    	if(id){
    		$scope.field = $scope.getQuestion(id);
    		$scope.modalSaveText = "Update"
    	} else {
    		// reset the question
    		$scope.resetQuestion();
    		$scope.modalSaveText = "Add"
    	}
    	//open modal
    	$('#additionalDetailQuestionEditModal').modal();
    };    
  	 
	 //This will determine if the min max values or values input boxes should be displayed in the add question modal
	 $scope.csvValuesRequired = false; 
	 $scope.minMaxValuesRequired = false;
	 $scope.minDisplay = "Minimum Length";
	 $scope.maxDisplay = "Maximum Length";
	 
	 $scope.$watch('field.kind', function(val){
		// default to false
		$scope.csvValuesRequired = false; 
		if(val =="radiobuttons" || val == "checkboxes" || val=="dropdown" || val=="multiDropdown"){
			$scope.csvValuesRequired = true;
		}
		// default to false
		$scope.minMaxValuesRequired = false;
		if(val=="text" || val== "textarea"){
			$scope.minMaxValuesRequired = true;
			$scope.minDisplay = "Minimum Length";
			$scope.maxDisplay = "Maximum Length";
		}
		else if(val=="number"){		
			$scope.minMaxValuesRequired = true;
			$scope.minDisplay = "Minimum Value";
			$scope.maxDisplay = "Maximum Value";
		}
	 });

		$scope.up= function(key){move(key, true);};
		$scope.down= function(key){move(key, false);};
		
		function move(key, up){
			for(var i=0; i<$scope.currentLineItemAD.additional_detail_form_array.length; i++){
				if($scope.currentLineItemAD.additional_detail_form_array[i].key==key){
					var row = $scope.currentLineItemAD.additional_detail_form_array[i];
					if(up==true && i != 0){
						$scope.currentLineItemAD.additional_detail_form_array[i] = $scope.currentLineItemAD.additional_detail_form_array[i-1];
						$scope.currentLineItemAD.additional_detail_form_array[i-1] = row;						
					}
					else if(up==false && i+1 !=$scope.currentLineItemAD.additional_detail_form_array.length){
						$scope.currentLineItemAD.additional_detail_form_array[i] = $scope.currentLineItemAD.additional_detail_form_array[i+1];
						$scope.currentLineItemAD.additional_detail_form_array[i+1] = row;
					}
					$scope.updateFormDefinition();
					break;
				}
			}
		};
	    
		function deleteById(id){
	    	//loop through schema keys
	    	for(key in $scope.currentLineItemAD.additional_detail_schema_hash.properties){
	    		if($scope.currentLineItemAD.additional_detail_schema_hash.properties[key].id == id){
	    			//remove from schema
	    			delete $scope.currentLineItemAD.additional_detail_schema_hash.properties[key];
	    			//look in required to see if key is inside
	    			if($scope.currentLineItemAD.additional_detail_schema_hash.required.indexOf(key) > -1){
	    				//remove if present
	    				$scope.currentLineItemAD.additional_detail_schema_hash.required.splice($scope.currentLineItemAD.additional_detail_schema_hash.required.indexOf(key), 1);
	    			}
	    			break;
	    		}
	    	}
	    	//loop through form array and remove id
	    	for(var i=0; i<$scope.currentLineItemAD.additional_detail_form_array.length; i++){
	    		if($scope.currentLineItemAD.additional_detail_form_array[i].id == id){
	    			$scope.currentLineItemAD.additional_detail_form_array.splice(i,1);
	    			break;
	    		}
	    	}
	    };
	    
	    //Will delete all questions
	    $scope.deleteAllQuestion = function(){
	    	for(key in $scope.currentLineItemAD.additional_detail_schema_hash.properties){
	    		deleteById(findByKey(key).id);
	    	}
	    	$scope.updateFormDefinition();
	    };
	    
	    $scope.deleteSelected = function() {
		    var rows = $scope.gridApi.selection.getSelectedRows($scope.gridModel);
		    for (var i=0; i<rows.length; i++) {
		    	deleteById(rows[i].id);
		  	}
		    $scope.updateFormDefinition();
	  	}; 
	  	
	  	$scope.addQuestion = function(ques){
	  		var question = hashCopy(ques);
	  		 //check to see if all required fields present
	  		if(question.key && question.name && question.kind){
	  			var keyValid = false;
	  			var questionSchema = $scope.currentLineItemAD.additional_detail_schema_hash.properties[question.key];
	  			//If a new question with no other key the key is valid
	  			if(!question.id && !questionSchema){
	  				keyValid = true;
	  			}
	  			//If editing question
	  			else if(questionSchema && questionSchema.id == question.id){
	  				keyValid = true;
	  			}
	  			//If changing key
	  			else if(question.id && !questionSchema && $scope.getQuestion(question.id)){
	  				var oldKey = $scope.getQuestion(question.id).key
	  				//remove old key from schema properties
					delete $scope.currentLineItemAD.additional_detail_schema_hash.properties[oldKey];
	  				//if in required remove it from there
					if ($scope.inRequired(oldKey)) {
					  removeRequired(oldKey) ;
					}
					keyValid = true;
				}
	  			//Else duplicate key present
	  			else{
	  				$scope.alertMessage = "Key already exists."; 				
	  				ques.key ='';
	  			}
	  			if(keyValid){
	  				//Add default description to date and time pickers
					if(question.description== null && (question.kind=="time" || question.kind=="datepicker")){
						question.description = (question.kind=="time") ? "ex. 12:00 AM" : "ex. 06/13/2015";
					  }
					// add to field form array
					var q = getForm(question); 
					//If new question
					if(!question.id){
						//Generate new id for question, unique value based on time
						question.id = uuid.v1();
						q.id = question.id;
		  				//And add to array
		  				$scope.currentLineItemAD.additional_detail_form_array.push(q);
					}
					//Find question in form array
					else{
						q.id = question.id
						//If not required but inside of required array, remove it
						if(!question.required && $scope.inRequired(question.key)){
							removeRequired(question.key);
					    }
						for(var i=0; i<$scope.currentLineItemAD.additional_detail_form_array.length; i++){
							//And update question
							if($scope.currentLineItemAD.additional_detail_form_array[i].id == question.id){
								$scope.currentLineItemAD.additional_detail_form_array[i] = q; 
								added=true;
							}
						}
					}
					//Update schema
					var s = getSchema(question);
					s.id = question.id;
					// add field to schema
					$scope.currentLineItemAD.additional_detail_schema_hash.properties[question.key] = s;
					//If required at it to required array if not already present
					if(question.required && !$scope.inRequired(question.key)){
						$scope.currentLineItemAD.additional_detail_schema_hash.required.push(question.key);
					}	    
		 		    // Lastly hide modal
					$('#additionalDetailQuestionEditModal').modal('hide');	
					$scope.updateFormDefinition();
	  			} 
	  		}
	  	};
	  		 
	 function removeRequired(key){
		 var index = $scope.currentLineItemAD.additional_detail_schema_hash.required.indexOf(key);
		 if(index > -1){
			 $scope.currentLineItemAD.additional_detail_schema_hash.required.splice(index, 1);
		 }
	 }
	  	
	 function findByKey(key){
		 if(key && $scope.currentLineItemAD.additional_detail_schema_hash.properties[key]){
			 var id = $scope.currentLineItemAD.additional_detail_schema_hash.properties[key].id
			 return (id) ? $scope.getQuestion(id) : null;
		 }
		 return null;
	 }
	  	
	 function hashCopy(hash){
		 var newHash={};
		 var keyList = Object.keys(hash);
		 for(var i=0;i<keyList.length;i++){
			 newHash[keyList[i]] = hash[keyList[i]];
		 }
		 return newHash;
	 }
	 
	 /* logic for conditional questions is not ready to be used because it needs fine tuning and testing  
	 $scope.$watch('field.conditionId', function(id){
		if(id){
			var question = $scope.getQuestion(id);
			if(question){
				$scope.conditionalTitleMap = question.titleMap
				$scope.conditionalEnum = (question.values) ? cleanSplit(question.values) : [];
			}
			// don't let admin users make conditional questions required
			$scope.field.required = false;
		} 
	 });
	 */
	 // disable the "Add/Edit Question" button if the question's values are incomplete
	 $scope.isValidQuestion = function(){
		         // key, name, and kind are required
		 return ($scope.field && $scope.field.key && $scope.field.name && $scope.field.kind
				 // if both have values, make sure min is not greater than max 
				 && (!$scope.field.min || !$scope.field.max || $scope.field.min <= $scope.field.max)
				 // CSV values required for certain types of questions
				 && (!$scope.csvValuesRequired || $scope.field.values));
	 };
	 
	 // returns a Form object to be added to the list of form fields.
	 function getForm(field){
		 var hash = {key: field.key, kind : field.kind, style: {'selected': 'btn-success',  'unselected': 'btn-default'}};
		 hash.values = field.values;
       /* logic for conditional questions is not ready to be used because it needs fine tuning and testing  
		 if(field.conditionId){
			 var questionType = $scope.getQuestion(field.conditionId).kind;
			 hash.conditionId = field.conditionId;
			 if(field.conditionValue){
				 if(questionType=="checkbox"){
					 hash.condition = "showByBoolean('"+field.conditionId+"','"+field.conditionValue + "')";
				 }
				 else{
					 hash.condition = "showByAnswer('"+field.conditionId+"','"+field.conditionValue + "')";
				 }
				 hash.conditionValue = field.conditionValue;
			 }
			 //If is number create conditional show based on min and max values
			 else if(field.conditionValueMin || field.conditionValueMax){
				 if(field.conditionValueMin && !field.conditionValueMax){
					 hash.condition = "showByAnswerGreaterThen('"+field.conditionId+"',"+field.conditionValueMin+","+field.minInclusive+")";
				 }
				 else if(!field.conditionValueMin && field.conditionValueMax){
					 hash.condition = "showByAnswerLessThen('"+field.conditionId+"',"+field.conditionValueMax+","+field.maxInclusive+")";
				 }
				 else{
					 hash.condition = "showByAnswerRange('"+field.conditionId+"',"+field.conditionValueMin+","+field.conditionValueMax+","+field.minInclusive+","+field.maxInclusive+")";
				 }
				 hash.conditionValueMin = field.conditionValueMin;
				 hash.conditionValueMax = field.conditionValueMax;
				 hash.minInclusive = field.minInclusive;
				 hash.maxInclusive = field.maxInclusive;
			 }
			 else if(field.conditionStartDate || field.conditionEndDate){
				 hash.condition = "showByDateRange('"+field.conditionId+"','"+field.conditionStartDate+"','"+field.conditionEndDate+"')";
				 hash.conditionStartDate = field.conditionStartDate;
				 hash.conditionEndDate = field.conditionEndDate;
			 }
		 }
		 */
		 hash.placeholder =  field.required ? "Required" : "Optional";
		 
		 if(field.kind == "yesNo"){
			 hash.type = "radiobuttons";
			 hash.values ="yes,no";
			 hash.titleMap= [{"value": "yes","name": "Yes"},{"value": "no","name": "No"}];
			 hash.description =  field.description ? field.description+" ("+(field.required ? "required" : "optional")+")" : field.required ? "Required" : "Optional";
			 return hash; 
		 } else if(field.kind == "state"){
			 hash.placeholder="Select One ("+(field.required ? "required" : "optional")+")";
			 hash.type = "strapselect";
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
		 } else if(field.kind == 'country'){
			 hash.placeholder="Select One ("+(field.required ? "required" : "optional")+")";
			 hash.type = "strapselect";
			 hash.titleMap = [{"value" : "US" ,"name" : "United States"}, {"value" : "AF" ,"name" : "Afghanistan"}, {"value" : "AX" ,"name" : "Åland Islands"}, {"value" : "AL" ,"name" : "Albania"}, {"value" : "DZ" ,"name" : "Algeria"}, {"value" : "AS" ,"name" : "American Samoa"}, 
			                  {"value" : "AD" ,"name" : "Andorra"}, {"value" : "AO" ,"name" : "Angola"}, {"value" : "AI" ,"name" : "Anguilla"}, {"value" : "AQ" ,"name" : "Antarctica"}, {"value" : "AG" ,"name" : "Antigua and Barbuda"}, {"value" : "AR" ,"name" : "Argentina"}, {"value" : "AM" ,"name" : "Armenia"}, 
			                  {"value" : "AW" ,"name" : "Aruba"}, {"value" : "AU" ,"name" : "Australia"}, {"value" : "AT" ,"name" : "Austria"}, {"value" : "AZ" ,"name" : "Azerbaijan"}, {"value" : "BS" ,"name" : "Bahamas"}, {"value" : "BH" ,"name" : "Bahrain"}, {"value" : "BD" ,"name" : "Bangladesh"}, 
			                  {"value" : "BB" ,"name" : "Barbados"}, {"value" : "BY" ,"name" : "Belarus"}, {"value" : "BE" ,"name" : "Belgium"}, {"value" : "BZ" ,"name" : "Belize"}, {"value" : "BJ" ,"name" : "Benin"}, {"value" : "BM" ,"name" : "Bermuda"}, {"value" : "BT" ,"name" : "Bhutan"}, 
			                  {"value" : "BO" ,"name" : "Bolivia, Plurinational State Of"}, {"value" : "BQ" ,"name" : "Bonaire, Sint Eustatius and Saba"}, {"value" : "BA" ,"name" : "Bosnia and Herzegovina"}, {"value" : "BW" ,"name" : "Botswana"}, {"value" : "BV" ,"name" : "Bouvet Island"}, 
			                  {"value" : "BR" ,"name" : "Brazil"}, {"value" : "IO" ,"name" : "British Indian Ocean Territory"}, {"value" : "BN" ,"name" : "Brunei Darussalam"}, {"value" : "BG" ,"name" : "Bulgaria"}, {"value" : "BF" ,"name" : "Burkina Faso"}, {"value" : "BI" ,"name" : "Burundi"}, 
			                  {"value" : "KH" ,"name" : "Cambodia"}, {"value" : "CM" ,"name" : "Cameroon"}, {"value" : "CA" ,"name" : "Canada"}, {"value" : "CV" ,"name" : "Cape Verde"}, {"value" : "KY" ,"name" : "Cayman Islands"}, {"value" : "CF" ,"name" : "Central African Republic"}, {"value" : "TD" ,"name" : "Chad"}, 
			                  {"value" : "CL" ,"name" : "Chile"}, {"value" : "CN" ,"name" : "China"}, {"value" : "CX" ,"name" : "Christmas Island"}, {"value" : "CC" ,"name" : "Cocos (Keeling) Islands"}, {"value" : "CO" ,"name" : "Colombia"}, {"value" : "KM" ,"name" : "Comoros"}, {"value" : "CG" ,"name" : "Congo"}, 
			                  {"value" : "CD" ,"name" : "Congo, The Democratic Republic Of The"}, {"value" : "CK" ,"name" : "Cook Islands"}, {"value" : "CR" ,"name" : "Costa Rica"}, {"value" : "CI" ,"name" : "Côte D'Ivoire"}, {"value" : "HR" ,"name" : "Croatia"}, {"value" : "CU" ,"name" : "Cuba"}, {"value" : "CW" ,"name" : "Curaçao"}, 
			                  {"value" : "CY" ,"name" : "Cyprus"}, {"value" : "CZ" ,"name" : "Czech Republic"}, {"value" : "DK" ,"name" : "Denmark"}, {"value" : "DJ" ,"name" : "Djibouti"}, {"value" : "DM" ,"name" : "Dominica"}, {"value" : "DO" ,"name" : "Dominican Republic"}, {"value" : "EC" ,"name" : "Ecuador"}, {"value" : "EG" ,"name" : "Egypt"}, 
			                  {"value" : "SV" ,"name" : "El Salvador"}, {"value" : "GQ" ,"name" : "Equatorial Guinea"}, {"value" : "ER" ,"name" : "Eritrea"}, {"value" : "EE" ,"name" : "Estonia"}, {"value" : "ET" ,"name" : "Ethiopia"}, {"value" : "FK" ,"name" : "Falkland Islands (Malvinas)"}, {"value" : "FO" ,"name" : "Faroe Islands"}, 
			                  {"value" : "FJ" ,"name" : "Fiji"}, {"value" : "FI" ,"name" : "Finland"}, {"value" : "FR" ,"name" : "France"}, {"value" : "GF" ,"name" : "French Guiana"}, {"value" : "PF" ,"name" : "French Polynesia"}, {"value" : "TF" ,"name" : "French Southern Territories"}, {"value" : "GA" ,"name" : "Gabon"}, 
			                  {"value" : "GM" ,"name" : "Gambia"}, {"value" : "GE" ,"name" : "Georgia"}, {"value" : "DE" ,"name" : "Germany"}, {"value" : "GH" ,"name" : "Ghana"}, {"value" : "GI" ,"name" : "Gibraltar"}, {"value" : "GR" ,"name" : "Greece"}, {"value" : "GL" ,"name" : "Greenland"}, {"value" : "GD" ,"name" : "Grenada"}, 
			                  {"value" : "GP" ,"name" : "Guadeloupe"}, {"value" : "GU" ,"name" : "Guam"}, {"value" : "GT" ,"name" : "Guatemala"}, {"value" : "GG" ,"name" : "Guernsey"}, {"value" : "GN" ,"name" : "Guinea"}, {"value" : "GW" ,"name" : "Guinea-Bissau"}, {"value" : "GY" ,"name" : "Guyana"}, 
			                  {"value" : "HT" ,"name" : "Haiti"}, {"value" : "HM" ,"name" : "Heard Island and Mcdonald Islands"}, {"value" : "VA" ,"name" : "Holy See (Vatican City State)"}, {"value" : "HN" ,"name" : "Honduras"}, {"value" : "HK" ,"name" : "Hong Kong"}, {"value" : "HU" ,"name" : "Hungary"}, 
			                  {"value" : "IS" ,"name" : "Iceland"}, {"value" : "IN" ,"name" : "India"}, {"value" : "ID" ,"name" : "Indonesia"}, {"value" : "IR" ,"name" : "Iran, Islamic Republic Of"}, {"value" : "IQ" ,"name" : "Iraq"}, {"value" : "IE" ,"name" : "Ireland"}, {"value" : "IM" ,"name" : "Isle Of Man"}, 
			                  {"value" : "IL" ,"name" : "Israel"}, {"value" : "IT" ,"name" : "Italy"}, {"value" : "JM" ,"name" : "Jamaica"}, {"value" : "JP" ,"name" : "Japan"}, {"value" : "JE" ,"name" : "Jersey"}, {"value" : "JO" ,"name" : "Jordan"}, {"value" : "KZ" ,"name" : "Kazakhstan"}, {"value" : "KE" ,"name" : "Kenya"}, 
			                  {"value" : "KI" ,"name" : "Kiribati"}, {"value" : "KP" ,"name" : "Korea, Democratic People's Republic Of"}, {"value" : "KR" ,"name" : "Korea, Republic Of"}, {"value" : "KW" ,"name" : "Kuwait"}, {"value" : "KG" ,"name" : "Kyrgyzstan"}, {"value" : "LA" ,"name" : "Lao People's Democratic Republic"}, 
			                  {"value" : "LV" ,"name" : "Latvia"}, {"value" : "LB" ,"name" : "Lebanon"}, {"value" : "LS" ,"name" : "Lesotho"}, {"value" : "LR" ,"name" : "Liberia"}, {"value" : "LY" ,"name" : "Libya"}, {"value" : "LI" ,"name" : "Liechtenstein"}, {"value" : "LT" ,"name" : "Lithuania"}, {"value" : "LU" ,"name" : "Luxembourg"}, 
			                  {"value" : "MO" ,"name" : "Macao"}, {"value" : "MK" ,"name" : "Macedonia, The Former Yugoslav Republic Of"}, {"value" : "MG" ,"name" : "Madagascar"}, {"value" : "MW" ,"name" : "Malawi"}, {"value" : "MY" ,"name" : "Malaysia"}, {"value" : "MV" ,"name" : "Maldives"}, {"value" : "ML" ,"name" : "Mali"}, 
			                  {"value" : "MT" ,"name" : "Malta"}, {"value" : "MH" ,"name" : "Marshall Islands"}, {"value" : "MQ" ,"name" : "Martinique"}, {"value" : "MR" ,"name" : "Mauritania"}, {"value" : "MU" ,"name" : "Mauritius"}, {"value" : "YT" ,"name" : "Mayotte"}, {"value" : "MX" ,"name" : "Mexico"}, 
			                  {"value" : "FM" ,"name" : "Micronesia, Federated States Of"}, {"value" : "MD" ,"name" : "Moldova, Republic Of"}, {"value" : "MC" ,"name" : "Monaco"}, {"value" : "MN" ,"name" : "Mongolia"}, {"value" : "ME" ,"name" : "Montenegro"}, {"value" : "MS" ,"name" : "Montserrat"}, {"value" : "MA" ,"name" : "Morocco"}, 
			                  {"value" : "MZ" ,"name" : "Mozambique"}, {"value" : "MM" ,"name" : "Myanmar"}, {"value" : "NA" ,"name" : "Namibia"}, {"value" : "NR" ,"name" : "Nauru"}, {"value" : "NP" ,"name" : "Nepal"}, {"value" : "NL" ,"name" : "Netherlands"}, {"value" : "NC" ,"name" : "New Caledonia"}, 
			                  {"value" : "NZ" ,"name" : "New Zealand"}, {"value" : "NI" ,"name" : "Nicaragua"}, {"value" : "NE" ,"name" : "Niger"}, {"value" : "NG" ,"name" : "Nigeria"}, {"value" : "NU" ,"name" : "Niue"}, {"value" : "NF" ,"name" : "Norfolk Island"}, {"value" : "MP" ,"name" : "Northern Mariana Islands"}, 
			                  {"value" : "NO" ,"name" : "Norway"}, {"value" : "OM" ,"name" : "Oman"}, {"value" : "PK" ,"name" : "Pakistan"}, {"value" : "PW" ,"name" : "Palau"}, {"value" : "PS" ,"name" : "Palestine, State Of"}, {"value" : "PA" ,"name" : "Panama"}, {"value" : "PG" ,"name" : "Papua New Guinea"}, {"value" : "PY" ,"name" : "Paraguay"}, 
			                  {"value" : "PE" ,"name" : "Peru"}, {"value" : "PH" ,"name" : "Philippines"}, {"value" : "PN" ,"name" : "Pitcairn"}, {"value" : "PL" ,"name" : "Poland"}, {"value" : "PT" ,"name" : "Portugal"}, {"value" : "PR" ,"name" : "Puerto Rico"}, {"value" : "QA" ,"name" : "Qatar"}, {"value" : "RE" ,"name" : "Réunion"}, 
			                  {"value" : "RO" ,"name" : "Romania"}, {"value" : "RU" ,"name" : "Russian Federation"}, {"value" : "RW" ,"name" : "Rwanda"}, {"value" : "BL" ,"name" : "Saint Barthélemy"}, {"value" : "SH" ,"name" : "Saint Helena, Ascension and Tristan Da Cunha"}, {"value" : "KN" ,"name" : "Saint Kitts and Nevis"}, 
			                  {"value" : "LC" ,"name" : "Saint Lucia"}, {"value" : "MF" ,"name" : "Saint Martin (French Part)"}, {"value" : "PM" ,"name" : "Saint Pierre and Miquelon"}, {"value" : "VC" ,"name" : "Saint Vincent and The Grenadines"}, {"value" : "WS" ,"name" : "Samoa"}, {"value" : "SM" ,"name" : "San Marino"}, 
			                  {"value" : "ST" ,"name" : "Sao Tome and Principe"}, {"value" : "SA" ,"name" : "Saudi Arabia"}, {"value" : "SN" ,"name" : "Senegal"}, {"value" : "RS" ,"name" : "Serbia"}, {"value" : "SC" ,"name" : "Seychelles"}, {"value" : "SL" ,"name" : "Sierra Leone"}, {"value" : "SG" ,"name" : "Singapore"}, 
			                  {"value" : "SX" ,"name" : "Sint Maarten (Dutch Part)"}, {"value" : "SK" ,"name" : "Slovakia"}, {"value" : "SI" ,"name" : "Slovenia"}, {"value" : "SB" ,"name" : "Solomon Islands"}, {"value" : "SO" ,"name" : "Somalia"}, {"value" : "ZA" ,"name" : "South Africa"}, 
			                  {"value" : "GS" ,"name" : "South Georgia and The South Sandwich Islands"}, {"value" : "SS" ,"name" : "South Sudan"}, {"value" : "ES" ,"name" : "Spain"}, {"value" : "LK" ,"name" : "Sri Lanka"}, {"value" : "SD" ,"name" : "Sudan"}, {"value" : "SR" ,"name" : "Suriname"}, 
			                  {"value" : "SJ" ,"name" : "Svalbard and Jan Mayen"}, {"value" : "SZ" ,"name" : "Swaziland"}, {"value" : "SE" ,"name" : "Sweden"}, {"value" : "CH" ,"name" : "Switzerland"}, {"value" : "SY" ,"name" : "Syrian Arab Republic"}, {"value" : "TW" ,"name" : "Taiwan, Province Of China"}, 
			                  {"value" : "TJ" ,"name" : "Tajikistan"}, {"value" : "TZ" ,"name" : "Tanzania, United Republic Of"}, {"value" : "TH" ,"name" : "Thailand"}, {"value" : "TL" ,"name" : "Timor-Leste"}, {"value" : "TG" ,"name" : "Togo"}, {"value" : "TK" ,"name" : "Tokelau"}, {"value" : "TO" ,"name" : "Tonga"}, 
			                  {"value" : "TT" ,"name" : "Trinidad and Tobago"}, {"value" : "TN" ,"name" : "Tunisia"}, {"value" : "TR" ,"name" : "Turkey"}, {"value" : "TM" ,"name" : "Turkmenistan"}, {"value" : "TC" ,"name" : "Turks and Caicos Islands"}, {"value" : "TV" ,"name" : "Tuvalu"}, {"value" : "UG" ,"name" : "Uganda"}, 
			                  {"value" : "UA" ,"name" : "Ukraine"}, {"value" : "AE" ,"name" : "United Arab Emirates"}, {"value" : "GB" ,"name" : "United Kingdom"}, {"value" : "UM" ,"name" : "United States Minor Outlying Islands"}, {"value" : "UY" ,"name" : "Uruguay"}, {"value" : "UZ" ,"name" : "Uzbekistan"}, 
			                  {"value" : "VU" ,"name" : "Vanuatu"}, {"value" : "VE" ,"name" : "Venezuela, Bolivarian Republic Of"}, {"value" : "VN" ,"name" : "Vietnam"}, {"value" : "VG" ,"name" : "Virgin Islands, British"}, {"value" : "VI" ,"name" : "Virgin Islands, U.S."}, {"value" : "WF" ,"name" : "Wallis and Futuna"}, 
			                  {"value" : "EH" ,"name" : "Western Sahara"}, {"value" : "YE" ,"name" : "Yemen"}, {"value" : "ZM" ,"name" : "Zambia"}, {"value" : "ZW" ,"name" : "Zimbabwe"}];
			 return hash;
		 } 
		 else if(field.kind == "email"){
			 hash.type = "string";
			 hash.placeholder ="ex. youremail@email.com ("+(field.required ? "required" : "optional")+")";
			 return hash;
		 }
		 else if(field.kind =="dropdown"){
			 hash.type = "strapselect";
			 hash.placeholder="Select One ("+(field.required ? "required" : "optional")+")";
			 hash.titleMap = getTileMap((field.values) ? cleanSplit(field.values) : []); 
			 return hash;
			 }
		 else if(field.kind == "phone"){
			 hash.type = "string";
			 hash.placeholder = "ex. 555-555-5555 ("+(field.required ? "required" : "optional")+")";
			 return hash;
		 }
		 else if(field.kind == "multiDropdown"){
			 hash.type = "strapselect";
			 hash.options = {multiple : true}; 
			 hash.placeholder="Select One or More ("+(field.required ? "required" : "optional")+")";
			 hash.titleMap = getTileMap((field.values) ? cleanSplit(field.values) : []);
			 return hash
		 }
		 else if(field.kind == "datepicker"){
			 hash.type = "datepicker";
			 hash.dateOptions = { "dateFormat" : "MM/dd/yyyy"  };
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
				  };
			 return hash;
		 }
		 else if(field.kind == "zipcode"){
			 hash.type = "string";
			 hash.placeholder = "ex. 55555 or 55555-5555 ("+(field.required ? "required" : "optional")+")";
			 return hash;
		 }
		 else if(field.kind == "checkboxes"){
			hash.type = field.kind;
			hash.titleMap = getTileMap((field.values) ? cleanSplit(field.values) : []);
			hash.description =  field.description ? field.description+" ("+(field.required ? "required" : "optional")+")" : field.required ? "Required" : "Optional";
			return hash;
		 }
		 else if(field.kind == "radiobuttons"){
			 hash.type = field.kind;
			 hash.titleMap = getTileMap((field.values) ? cleanSplit(field.values) : []);
			 hash.description =  field.description ? field.description+" ("+(field.required ? "required" : "optional")+")" : field.required ? "Required" : "Optional";
			 return hash;
		 }
		 else if(field.kind == "checkbox"){
			 hash.type =field.kind;
			 hash.values = "true, false"
			 return hash;
		 }
		 else{
			 hash.type =field.kind;
			 return hash;
		 }
	 };
	 
	 function cleanSplit(value){
		 var list = value.split(","); 
		 var cleanList=[];
		 for(var i=0; i<list.length; i++){
			 var e = list[i].trim();
			 if(e != ''){
				 cleanList.push(e);
			 }
		 }
		 return cleanList;
	 }
	 
	 function getTileMap(list){
		 var tileMap =[];
		 for(var i=0; i<list.length; i++){
			 var tile = {value : list[i], name : list[i]};
			 tileMap.push(tile);	 
		 }
		 return tileMap;
	 }
	 
	 // returns a form input field's schema definition with default configuration values for specific types (e.g., Yes/No, date picker)
	 function getSchema(field){			 
		var hash = {title: field.name, description : field.description};
	 	 if(field.kind =="datepicker") {
	 		 hash.type = "string"; 
	 		 hash.format = "datepicker"; 
	 		 hash.validationMessage = "Please enter a valid date ex. 06/13/2015";	 			
	 	 }
	 	 else if(field.kind == "text" || field.kind == "textarea"){
	 		hash.type = "string";
	 		if(field.min != null){
	 			hash.minLength = field.min;
	 		}
	 		if(field.max != null){
	 			hash.maxLength = field.max;
	 		}
	 	 }
		 else if(field.kind == "yesNo"){
			 hash["enum"] = ["yes","no"]; 
			 hash.type="string";	
		 }
		 else if(field.kind == "state"){
			 hash.type = "string"; 
		 }
		 else if(field.kind == "country"){
			 hash.type = "string";
		 }
		 else if(field.kind == "multiDropdown"){
			 hash.items = {"type": "string"}; 
			 hash.type = "array"; 
		 }
		 else if(field.kind == "phone"){
			hash.type = "string"; 
			hash.pattern = "^[0-9]{3}-[0-9]{3}-[0-9]{4}$"; 
			hash.validationMessage = "Please enter a valid phone number.";	
		 }
		 else if(field.kind == "radiobuttons"){
			 hash["enum"] = (field.values) ? cleanSplit(field.values)  : [];
			 hash.type = "string"; 	
		 }
		else if(field.kind == "file"){
			hash.type = "string";	
		}
		else if(field.kind == "dropdown"){
			 hash.type = "string";
		}
		else if(field.kind =="checkboxes"){
			hash.items = {"type": "string", "enum": (field.values) ? cleanSplit(field.values)  : []};
			hash.type = "array";
		}
		else if(field.kind == "email"){
			hash.type = "string"; 
			hash.pattern = "^\\S+@\\S+$"; 
			hash.validationMessage = "Please enter a valid email.";
		}
		else if(field.kind == "zipcode"){
			hash.type = "string"; 
			hash.pattern = "^[0-9]{5}(-[0-9]{4})?$"; 
			hash.validationMessage = "Please enter a valid zip code.";
		}
		else if(field.kind == "time"){
			hash.validationMessage = "Please enter a valid time ex. 12:00 AM"; 
			hash.type = "string";
			hash.format = "timepicker";
		}
		else if(field.kind == "checkbox"){
			hash.type = "boolean";
		}
		else if(field.kind == "number"){
	 		if(field.min != null){
	 			hash.minimum = field.min;
	 		}
	 		if(field.max != null){
	 			hash.maximum = field.max;
	 		}
			hash.type = "integer";
		}
		else if(field.kind == "range"){
			if(field.min != null){
				hash.minimum = field.min;
			}
	 		if(field.max != null){
	 			hash.maximum = field.max;
	 		}
	 		hash.type = field.kind;	
		}
		else{
			hash.type = "string";
		}
	 	 return hash;
	 };
}]);