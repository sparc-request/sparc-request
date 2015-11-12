angular.module('app').controller('QuestionsFormController', ['$scope', function ($scope) {
    
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
    	var matchingKey, schemaQuestion, formQuestion;
    	for(var key in $scope.currentLineItemAD.additional_detail_schema_hash.properties){
    		if($scope.currentLineItemAD.additional_detail_schema_hash.properties[key].id ==id){
    			schemaQuestion = $scope.currentLineItemAD.additional_detail_schema_hash.properties[key];
    			matchingKey = key;
    		}
    	}
    	for(var i=0; i<$scope.currentLineItemAD.additional_detail_form_array.length; i++){
    		if($scope.currentLineItemAD.additional_detail_form_array[i].id == id){
    			formQuestion = $scope.currentLineItemAD.additional_detail_form_array[i];
    		}
    	}
    	var question = {};
    	var required = false;
    	if(matchingKey && schemaQuestion && formQuestion){
	    	question.name = schemaQuestion.title;
	    	question.key = matchingKey;
	    	question.id = id
	    	question.titleMap = formQuestion.titleMap;
	    	/*  logic for conditional questions is not ready to be used because it needs fine tuning and testing 
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
	    	} */
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
}]);