$('#submissionModal .modal-body').html("<%= j render 'form' %>")
$('#submissionModal .modal-footer').html("<a href='javascript:void(0)' class='btn btn-primary update-submission' data-id='<%=@submission.id %>'>Update Submission</a>")
$('#submissionModal').modal('show')
