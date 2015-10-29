angular.module('app').controller('FormCreationController', ['$scope', '$http', function ($scope, $http, $compile) {
	$scope.gridModel = {enableColumnMenus: false, enableFiltering: true,enableCellEdit: false, enableColumnResizing: true, showColumnFooter: false , enableSorting: false, showGridFooter: false, enableRowHeaderSelection: false, rowHeight: 45};
	$scope.gridModel.columnDefs = [
	                                 {name: 'Edit',enableFiltering: false, enableColumnResizing: false, width: 53, cellTemplate: '<button type="button" class="btn btn-primary" ng-click="grid.appScope.editQuestion(row.entity.id)">Edit</button>' },
	                                 {name: 'question', field: 'name',  width: '33%' }, 
	                                 {name: 'type', field: "kind", width: '15%'},
	                               	 {name: 'required', width :'12%'},
	                               	 {field: "description"},
	                               	 {enableFiltering: false,  enableColumnResizing: false,name:'Order', field :'up', width: 83, cellTemplate: '<button type="button" class="btn btn-primary glyphicon glyphicon-chevron-up" ng-click="grid.appScope.up(row.entity.key)"></button><button type="button" class="btn btn-primary glyphicon glyphicon-chevron-down" ng-click="grid.appScope.down(row.entity.key)"></button>'}
	                               	];
	
	$scope.form ={};
	$scope.model = {};
	
	//Displays result data that will be exported when a user requests a service and anaswers the questions
	$scope.pretty = function(){
		 return JSON.stringify($scope.model,undefined,2,2);
		 };
		 
	//Will hide results data if no data is present
	$scope.dataDisplay = function(){
		return (!$scope.pretty() || $scope.pretty()=="{}") ? "display : none" : "";
		} 

	//Required to use datepicker
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
	
	//used is setting display text for dropdown

	$scope.invaildDate = new Date((new Date()-86400000));
	
	//Creates formDefinition String, will populate if null
    $scope.formDefinition = ($('#additional_detail_form_definition_json').val() != "") ? $('#additional_detail_form_definition_json').val() : JSON.stringify({ schema: { type: "object",title: "Comment", properties: {},required: []}, form: []},undefined,2);
    
    //Uses a key name to populate add/edit question model with question data, if key==null then a new question will be created
    
    $scope.getFormDefinition = function(){
    	return JSON.parse($scope.formDefinition);
    }
    
    $scope.setFormDefinition = function(formDef){
    	$scope.formDefinition = JSON.stringify(formDef,undefined,2,2);
    }
    
    $scope.resetQuestion = function(){$scope.field = {};}
    
    $scope.getSchemaParsed = function(){
    	return $scope.getFormDefinition().schema;
    }
    
    $scope.getRequired = function(){
    	var required = $scope.getSchemaParsed().required
    	return (required) ? required : [];
    }
    
    $scope.getFormParsed = function(){
    	return $scope.getFormDefinition().form;
    }
    
    $scope.noQuestions = function(){
    	return $scope.getFormParsed().length == 0 ;
    }
    
    //Taking a id as input this function will return a question hash with all relevent data
    $scope.getQuestion =  function(id){ 
    	//loop through hashkeys in schema and find object with same id
    	var schemaQuestion;
    	var properties = $scope.getSchemaParsed().properties
    	for(var key in properties){
    		if(properties[key].id ==id){
    			schemaQuestion = properties[key];
    		}
    	}
    	
    	var form = $scope.getFormParsed();
    	var formQuestion;
    	for(var i=0; i<form.length; i++){
    		if(form[i].id == id){
    			formQuestion = form[i];
    		}
    	}
    	var question = {};
    	var required = false;
    	
    	if(schemaQuestion && formQuestion){
	    	question.name = schemaQuestion.title;
	    	question.key = formQuestion.key;
	    	question.id = id
	    	question.values = formQuestion.values;
	    	question.kind = formQuestion.kind;
	    	question.description = schemaQuestion.description;
	    	question.min = (schemaQuestion.minLength) ? schemaQuestion.minLength : schemaQuestion.minimum;
	    	question.max = (schemaQuestion.maxLength) ? schemaQuestion.maxLength : schemaQuestion.maximum;
	    	question.required = inRequired(formQuestion.key);
	    	
	    	return question;
    	}else{
    		return null;
    	}
    }
    
    $scope.editQuestion = function(id){
		// hide the alert message before showing new question
		$scope.alertMessage = null;
		
    	//find key if it exists
    	if(key){
    		$scope.field = $scope.getQuestion(id);
    		$scope.modalSaveText = "Update"
    	}
    	else{
    		$scope.resetQuestion();
    		$scope.modalSaveText = "Add"
    	}
    	
    	//open modal
    	$scope.showModal();
    	
    }
    
    $scope.hideModal = function(){
    	$('#additionalDetailQuestionEditModal').modal('hide');
    }
    
    $scope.showModal = function(){
    	$('#additionalDetailQuestionEditModal').modal();
    }
    
	 var dropdownKindList = ["multiDropdown", "dropdown", "state", "country"];
	 function generateGridArray(schema, form){
		 var gridArray = [];
		 for (var x=0; x < form.length; x++){
			 gridArray.push($scope.getQuestion(form[x].id));
		  }
		 return gridArray;
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
 	
	  // form def management
	  // default type to text for new fields
	  $scope.field = {};
	  // select list options
	  
	  $scope.keyError = function(){
	  		return ($scope.field && $scope.field.key && findByKey($scope.field.key)) ? "Key already exists." : "Please fill out this field. Valid characters are A-Z a-z 0-9";
	  }
	  
	 
	 //This will determine if the min max values or values input boxes shouldd be displayed in the add question modal
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
	   
	  $scope.formKeySet = function(){
		  return Objects.keys($scope.model.form);
	  };
	  
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
					$scope.setFormDefinition(formDef);
					break;
				}
			}
		}
		
		$scope.gridModel.onRegisterApi = function(gridApi){
			$scope.gridApi = gridApi;
			
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
	    
	    $scope.deleteById = function(id){
	    	var formDef = JSON.parse($scope.formDefinition);
	    	//loop through schema keys
	    	for(key in formDef.schema.properties){
	    		var question = $scope.getSchemaParsed().properties[key];
	    		if(question.id == id){
	    			//remove from schema
	    			delete formDef.schema.properties[key];
	    			//remove any input value from data preview
	    			delete $scope.model[key];
	    			//look in required to see if key is inside
	    			var index = formDef.schema.required.indexOf(key);
	    			if(index > -1){
	    				//remove if present
	    				formDef.schema.required.splice(index, 1);
	    			}
	    			break;
	    		}
	    	}
	    	//loop through form array and remove id
	    	for(var i=0; i<formDef.form.length; i++){
	    		var question = formDef.form[i];
	    		if(question.id == id){
	    			formDef.form.splice(i,1);
	    			break;
	    		}
	    	}
	    	$scope.setFormDefinition(formDef);
	    }
	    
	    //Will delete all questions
	    $scope.deleteAllQuestion = function(){
	    	for(key in JSON.parse($scope.formDefinition).schema.properties){
	    		$scope.deleteById(findByKey(key).id);
	    	}
	    }
	    
	    $scope.deleteSelected = function() {
		    var rows = $scope.gridApi.selection.getSelectedRows($scope.gridModel);
		    for (var i=0; i<rows.length; i++) {
		    	$scope.deleteById(rows[i].id)
		  	}
	  	}; 
	  	
	  	
	  
	  	$scope.addQuestion = function(ques){
	  		var question = hashCopy(ques);
	  		 //check to see if all required fields present
	  		if(question.key && question.name && question.kind){
	  			var formDef = JSON.parse($scope.formDefinition)
	  			var keyVaild = false;
	  			var questionSchema = $scope.getSchemaParsed().properties[question.key];
	  			//If a new question with no other key the key is vaild
	  			if(!question.id && !questionSchema){
	  				keyVaild = true;
	  			}
	  			//If editing question
	  			else if(questionSchema && questionSchema.id == question.id){
	  				keyVaild = true;
	  			}
	  			//If changing key
	  			else if(question.id && !questionSchema && $scope.getQuestion(question.id)){
	  				var oldKey = $scope.getQuestion(question.id).key
	  				//remove old key from schema properties
					delete formDef.schema.properties[oldKey];
	  				//if in required remove it from there
					formDef.schema.required = (inRequired(oldKey)) ? removeRequired(oldKey) : formDef.schema.required;
					//remove from anaswers
					delete $scope.model[oldKey];
					keyVaild = true;
				}
	  			//Else duplicate key present
	  			else{
	  				$scope.alertMessage = "Key already exists."; 				
	  			//	$scope.field.key.$error.alreadyPresent ="Test";
	  				ques.key ='';
	  			}
	  			if(keyVaild){
	  				//Add default description to date and time pickers
					if(question.description== null && (question.kind=="time" || question.kind=="datepicker")){
						question.description = (question.kind=="time") ? "ex. 12:00 AM" : "ex. 06/13/2015";
					  }
					// add to field form array
					var q = $scope.getForm(question); 
					//If new question
					if(!question.id){
						//Generate new id for question, unique value based on time
						question.id = uuid.v1();
						q.id = question.id;
		  				//And add to array
		  				formDef.form.push(q);
					}
					//Find question in form array
					else{
						q.id = question.id
						//If not required but inside of required array, remove it
						if(!question.required && inRequired(question.key)){formDef.schema.required = removeRequired(question.key)}
						for(var i=0; i<formDef.form.length; i++){
							//And update question
							if(formDef.form[i].id == question.id){
								formDef.form[i] = q; 
								added=true;
							}
						}
					}
					//Update schema
					var s = $scope.getSchema(question);
					s.id = question.id;
					// add field to schema
					formDef.schema.properties[question.key] = s;
					//If required at it to required array if not already present
					if(question.required && !inRequired(question.key)){formDef.schema.required.push(question.key);}
					//Update form definition
					$scope.setFormDefinition(formDef);
					//Lastly hide modal
					$scope.hideModal();					
	  			} 
	  		}
	  	}
	  	
	 function inRequired(key){
		 var required = $scope.getRequired();
		 for(var i=0; i<required.length; i++){
 			if(required[i] == key){return true;}
 		}
		 return false;
	 }
	 
	 //Returns list of required keys with the key input removed
	 function removeRequired(key){
		 var index = $scope.getRequired().indexOf(key);
		 var required = JSON.parse($scope.formDefinition).schema.required;
		 if(index > -1){
			 required.splice(index, 1);
		 }
		 return required;
	 }
	  	
	 function findByKey(key){
		 if(key && $scope.getSchemaParsed().properties[key]){
			 var id = $scope.getSchemaParsed().properties[key].id
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
	 
	 var radioDefaultValues = ["1","2","3","4","5"]; 
	 $scope.getForm = function(field){
		 field.key = removeSpecial(field.key); // removes special characters
		 var hash = {key: field.key, kind : field.kind, style: {'selected': 'btn-success',  'unselected': 'btn-default'}};
		 hash.values = field.values;
		 
		 if(field.kind == "yesNo"){
			 hash.type = "radiobuttons"; 
			 hash.titleMap= [{"value": "yes","name": "Yes"},{"value": "no","name": "No"}];
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
			 hash.placeholder="Select One";
			 hash.titleMap = getTileMap((field.values) ? cleanSplit(field.values) : radioDefaultValues);  
			 hash.placeholder="Select One";
			 return hash;
			 }
		 else if(field.kind == "phone"){
			 hash.type = "string";
			 hash.placeholder = "ex. 555-555-5555"
			 return hash;
		 }
		 else if(field.kind == "multiDropdown"){
			 hash.type = "strapselect";
			 hash.placeholder="Select One";
			 hash.options = {multiple : true}; 
			 hash.placeholder ="Select One or More"
			 hash.titleMap = getTileMap((field.values) ? cleanSplit(field.values) : radioDefaultValues);
			 return hash
		 }
		 else if(field.kind == "datepicker"){
			 hash.type = "datepicker";
			 hash.dateOptions = {
					 "dateFormat" : "MM/dd/yyyy" 
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
			hash.titleMap = getTileMap((field.values) ? cleanSplit(field.values) : radioDefaultValues);
			return hash;
		 }
		 else if(field.kind == "radiobuttons"){
			 hash.type = field.kind;
			 hash.titleMap = getTileMap((field.values) ? cleanSplit(field.values) : radioDefaultValues);	
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
	 
	 function getTileMap(list){
		 var tileMap =[];
		 for(var i=0; i<list.length; i++){
			 var tile = {value : list[i], name : list[i]};
			 tileMap.push(tile);	 
		 }
		 return tileMap;
	 }
	 
	 //Will return false if field.min and field.max are invaild
	 $scope.validMinMax = function(){
		 return !$scope.field.min || !$scope.field.max || $scope.field.min <= $scope.field.max;
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
	 		hash.minLength = field.min;
	 		hash.maxLength = field.max;
	 		return hash;
	 	 }
		 else if(field.kind == "yesNo"){
			 hash["enum"] = ["yes","no"]; hash.type="string";
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
	 		hash.minimum = field.min;
	 		hash.maximum = field.max;
			hash.type = "integer";
			return hash;
		}
		else{
			hash.type = "string";
			return hash;
		}
		
	 }
  
}]);