$('#submissionModal .modal-body').html("<%= j render 'form' %>")
$('.submission-btn').remove()
$('#submissionModal .modal-footer').html("<a href='javascript:void(0)' class='btn btn-primary create-submission'> Create Submission</a>")
$('#submissionModal').modal('show')
