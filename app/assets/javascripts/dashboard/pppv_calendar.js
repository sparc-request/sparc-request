$(document).ready( function() {
  $('.selectpicker').selectpicker();

  // default x-editable error function throws error itself...
  $.fn.editable.defaults.error = function(response, newValue) {
    return false;
  }

  // override x-editable defaults
  $.fn.editable.defaults.send = 'always'
  $.fn.editable.defaults.ajaxOptions = {
    type: "PUT",
dataType: "script"
  };

$('.edit-subject-count').editable({
  title: 'Edit subject count',
  validate: function(val) {
    var n = ~~Number(val);
    var max_subject_count = $(this).data('max-subject-count');
    if(String(n) != val || n < 0) {
      return "quantity must be a nonnegative number";
    }
    else if(n > max_subject_count) {
      return "The N cannot exceed the maximum subject count of the arm (" + max_subject_count + ")";
    }
  }
});

$('.edit-your-cost').editable({
  title: 'Edit your cost',
  display: function(value) {
    // display field as currency, edit as quantity
    $(this).text("$" + parseFloat(value).toFixed(2));
  },
  validate: function(value) {
              var n = +value;
              if(isNaN(n) || n < 0) {
                return "cost must be a nonnegative number";
              }
            },
  params: function(params) {
            data = {'line_item': {'displayed_cost': params.value}};
            return data;
          }
});

validate_billing_qty = function(val) {
  var n = ~~Number(val);
  if(String(n) != val || n < 0) {
    return "quantity must be a positive number";
  }
};

$('.edit-research-billing-qty').editable({
  title: 'Edit research billing quantity',
  validate: validate_billing_qty
});
$('.edit-insurance-billing-qty').editable({
  title: 'Edit insurance billing quantity',
  validate: validate_billing_qty
});
$('.edit-effort-billing-qty').editable({
  title: 'Edit effort billing quantity',
  validate: validate_billing_qty
});
})
