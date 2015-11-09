angular.module('app').controller('ConditionFormController', ['$scope', function ($scope) {
    
    $scope.inRequired = function(key){
		 for(var i=0; i<$scope.currentLineItemAD.additional_detail_schema_hash.required.length; i++){
			if($scope.currentLineItemAD.additional_detail_schema_hash.required[i] == key){
				return true;
			}
		}
		 return false;
	 };
    
	//Taking a id as input this function will return a question hash with all relevent data
    $scope.getQuestion =  function(id){ 
    	//loop through hashkeys in schema and find object with same id
    	var schemaQuestion;
    	for(var key in $scope.currentLineItemAD.additional_detail_schema_hash.properties){
    		if($scope.currentLineItemAD.additional_detail_schema_hash.properties[key].id ==id){
    			schemaQuestion = $scope.currentLineItemAD.additional_detail_schema_hash.properties[key];
    		}
    	}

    	var formQuestion;
    	for(var i=0; i<$scope.currentLineItemAD.additional_detail_form_array.length; i++){
    		if($scope.currentLineItemAD.additional_detail_form_array[i].id == id){
    			formQuestion = $scope.currentLineItemAD.additional_detail_form_array[i];
    		}
    	}
    	var question = {};
    	var required = false;
    	if(schemaQuestion && formQuestion){
	    	question.name = schemaQuestion.title;
	    	question.key = formQuestion.key;
	    	question.id = id
	    	question.titleMap = formQuestion.titleMap;
	    	question.conditional = (formQuestion.condition != null);
	    	if(question.conditional){
	    		question.conditionId = formQuestion.conditionId;
	    		question.conditionValueMin = formQuestion.conditionValueMin;
	    		question.conditionValueMax = formQuestion.conditionValueMax;
	    		question.minInclusive = formQuestion.minInclusive;
	    		question.maxInclusive = formQuestion.maxInclusive;
	    		question.conditionValue = formQuestion.conditionValue;
	    		question.conditionStartDate = formQuestion.conditionStartDate;
	    		question.conditionEndDate = formQuestion.conditionEndDate
	    	}
	    	question.values = formQuestion.values;
	    	question.kind = formQuestion.kind;
	    	question.description = schemaQuestion.description;
	    	question.min = (schemaQuestion.minLength) ? schemaQuestion.minLength : schemaQuestion.minimum;
	    	question.max = (schemaQuestion.maxLength) ? schemaQuestion.maxLength : schemaQuestion.maximum;
	    	question.required = $scope.inRequired(formQuestion.key);
	    	return question;
    	}else{
    		return null;
    	}
    };
    
    $scope.showByAnswer = function(id, value){
		 var question = $scope.getQuestion(id);
		 if(question){
			 return $scope.currentLineItemAD.form_data_hash[question.key] == value;
		 }
		 return false;
	 };
	 
	 $scope.showByBoolean = function(id, value){
		 var question = $scope.getQuestion(id);
		 if(question){
			return $scope.currentLineItemAD.form_data_hash[question.key] == Boolean(value);
		 }
		 return false;
	 };
	 
	 $scope.showByDateRange = function(id, startDate, endDate){
		 var question = $scope.getQuestion(id);
		 if(question){
			 var value = Date.parse($scope.currentLineItemAD.form_data_hash[question.key]);
			 if(value){
				 var minInMillis = (startDate) ? Date.parse(startDate) : null;
				 var maxInMillis = (endDate) ? Date.parse(endDate) : null;
				 if(minInMillis && !maxInMillis){
					 return  value >= minInMillis;
				 }
				 else if(!minInMillis && maxInMillis){
					 return value <= maxInMillis;
				 }
				 else if(minInMillis && maxInMillis){
					 return value <= maxInMillis &&  value >= minInMillis;
				 }
				 return true;
			 }
		 }
		 return false;
	 };
	 
	 $scope.showByAnswerRange = function(id, minValue, maxValue, minInclusive, maxInclusive){
		 var question = $scope.getQuestion(id);
		 if(question){
			 var value = $scope.currentLineItemAD.form_data_hash[question.key];
			 if(minInclusive && !maxInclusive){
				 return value >= minValue && value < maxValue;
			 }
			 else if(!minInclusive && maxInclusive){
				 return value > minValue && value <= maxValue;
			 }
			 else if(!minInclusive && !maxInclusive){
				 return value > minValue && value < maxValue;
			 }
			 else{
				 return value >= minValue && value <= maxValue;
			 }
		 }
		 return false;
	 };
	 
	 $scope.showByTextInput = ['text','textarea',"email",'zipcode','phone','time',];
	 $scope.showByDropDown = ['radiobuttons',"dropdown",'multiDropdown','checkboxes',"yesNo",'checkbox'];
	 $scope.showByDropDownWithTitleMapping = ['state','country'];
	 
	 $scope.questionKindInArray = function(id, array){
		 var question = $scope.getQuestion(id);
		 if(question){
			 for(var i=0; i<array.length; i++){
				 if(array[i] == question.kind){
					 return true;
				 }
			 }
		 }
		 return false;
	 };
	 
	 $scope.showByAnswerGreaterThen = function(id, minValue, minInclusive){
		 var question = $scope.getQuestion(id);
		 if(question){
			 var value = $scope.currentLineItemAD.form_data_hash[question.key];
			 if(minInclusive){
				 return value >= minValue;
			 }
			 else{
				 return value > minValue;
			 }
		 }
		 return false;
	 };
	 
	 $scope.showByAnswerLessThen = function(id, maxValue, maxInclusive){
		 var question = $scope.getQuestion(id);
		 if(question){
			 var value = $scope.currentLineItemAD.form_data_hash[question.key];
			 if(value){
				 if(maxInclusive){
					 return value <= maxValue;
				 }
				 else{
					 return value < maxValue;
				 }
			 }
		 }
		 return false;
	 }
}]);