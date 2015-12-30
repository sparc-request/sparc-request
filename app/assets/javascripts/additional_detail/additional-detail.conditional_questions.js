angular.module('app').controller('ConditionalQuestionsFormController', ['$scope', function ($scope) {
  
  $scope.showByTextInput = ['text','textarea',"email",'zipcode','phone','time',];
  $scope.showByDropDown = ['radiobuttons',"dropdown",'multiDropdown','checkboxes',"yesNo",'checkbox'];
  $scope.showByDropDownWithTitleMapping = ['state','country'];
	 
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