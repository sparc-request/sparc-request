# encoding: UTF-8
# Question#is_mandatory is now false by default. The default_mandatory option allows you to set
#   is_mandatory for all questions in a survey.
survey "Data Request Form survey", :default_mandatory => false do
#####################################################
  section "Requestor's Contact Information" do
#####################################################    
    label "<h2>Requestor's Contact Information</h2>"
    
    q "First Name", :is_mandatory => true
    a :string
  #  validation :rule => "A"
  #  condition_A ">=", :integer_value => 0
    
    q "Last Name", :is_mandatory => true
    a :string
   # validation :rule => "Required"
    
    q "Department", :is_mandatory => true
    a :string
    
    q "Email", :is_mandatory => true
    a :string
    
    # Questions may also have input masks with fancy placeholders
    q "Phone Number"
    a :string, :input_mask => '(999)999-9999', :input_mask_placeholder => '#'
    
    q "Please provide a MFK for billing", :is_mandatory => true
    a :text, :help_text => "format : NNN-NN-NNNN-NNNNN-NNNNNNNN-NNNN-NNN-NNNNN-NN-NNNN Please note: Complex data requests are charged at a rate of $85.00/hour. Please contact us with questions."
#  end
#####################################################  
#  section "Data Request Details" do  
#####################################################    
    label "<h2>Data Request Details</h2>"
    
    q "Research Title", :is_mandatory => true
    a :string
    
    q "PI Name", :is_mandatory => true
    a :string
    
    q "PI Email"
    a :string
    
    # A basic question with radio buttons
    q_healthcare_ids "Does your team have healthcare Id's", :pick => :one 
    a_yes "Yes"
    a_no "No"
    
    q_healthcare_ids_yes "Please provide Healthcare id's of people who should get access to this dataset."
    a :text
    dependency :rule => "A"
    condition_A :q_healthcare_ids, "==", :a_yes
    condition_A :q_healthcare_ids, "count>0"
   
    q_healthcare_ids_no "Please provide the HawkId's of people who should get access to this dataset."
    a :text
    dependency :rule => "A"
    condition_A :q_healthcare_ids, "==", :a_no
    condition_A :q_healthcare_ids, "count>0"
    
    q_data_from_us_previously "Did you get any data from us previously?", :pick => :one
    a_yes "Yes"
    a_no "No"
    
    q "Please provide details on grants approved on the basis of data received previously:"
    a :string
    dependency :rule => "A"
    condition_A :q_data_from_us_previously, "==", :a_yes
    condition_A :q_data_from_us_previously, "count>0"
    
    q "Please provide details on publications from the previous data"
    a :string
    dependency :rule => "A"
    condition_A :q_data_from_us_previously, "==", :a_yes
    condition_A :q_data_from_us_previously, "count>0"
    
    q_request_type "Request Type", :pick => :one, :display_type => :dropdown
    a_1 "Statistical Complication"
    a_2 "Research"
    a_3 "Quality Assurance"
    a_4 "Operational"
    a_5 "Grant Submission"
    a_6 "Inquiry"
    
    q "Description of the research", :pick => :one, :display_type => :dropdown
    a "NIH funded ongoing research"
    a "Non-NIH, non-pharmaceutical ongoing research"
    a "Ongoing pharmaceutical supported research"
    a "Research to support Grant application (pilot study)"
    a "Research to support pharmaceutical supported study (pilot study)"
    a "Research to support students or trainee projects"
    a "FDA funded research"
    
    q "Grant Name"
    a :string
    
    q "Grant (RFA) Number"
    a :string
    
    q "Funding agency"
    a :string
    
    q "Grant Submission Date"
    a :date
    dependency :rule => "A"
    condition_A :q_request_type, "==", :a_5
    condition_A :q_request_type, "count>0"
    
    q "Description"
    a :text
    
    q_data_type "Data Type", :pick => :one
    a_identified "Identified Patient Data"
    a_deidentified "De-Identified Patient Data"
    
    q "IRB Number"
    a :string
    dependency :rule => "A"
    condition_A :q_data_type, "==", :a_identified
    condition_A :q_data_type, "count>0"
    
    q_irb_protocol "IRB Protocol", :pick => :one
    a_applied "Applied"
    a_approved "Approved"
    dependency :rule => "A"
    condition_A :q_data_type, "==", :a_identified
    condition_A :q_data_type, "count>0"
    
    q "IRB Protocol approval document [Upload Document]"
#    a :string
    dependency :rule => "A"
    condition_A :q_irb_protocol, "==", :a_approved
    condition_A :q_irb_protocol, "count>0"
    
    q "IRB Protocol details document [Upload Document]"
#    a :string
    dependency :rule => "A"
    condition_A :q_irb_protocol, "==", :a_approved
    condition_A :q_irb_protocol, "count>0"
    
    q "List of MRNs approved and consented [Upload Document]"
#    a :string
    dependency :rule => "A"
    condition_A :q_data_type, "==", :a_identified
    condition_A :q_data_type, "count>0"
#  end
#####################################################   
#section "Data Extraction Criteria" do  
#####################################################
    label "<h2>Data Extraction Criteria</h2>"

    q "Patient Inclusion Criteria"
    a :text
    
    q "Patient Exclusion Criteria"
    a :text
    
    q_demographics "Select data fields for Demographic data?", :pick => :one
    a_yes "Yes"
    a_no "no"
    
    q "Demographic Inclusion Criteria"
    a :text
    dependency :rule => "A"
    condition_A :q_demographics, "==", :a_yes
    condition_A :q_demographics, "count>0"
    
    q "Demographic Exclusion Criteria"
    a :text
    dependency :rule => "A"
    condition_A :q_demographics, "==", :a_yes
    condition_A :q_demographics, "count>0"
    
    q_diagnosis "Diagnosis & Problem List needed?", :pick => :one
    a_yes "Yes"
    a_no "no"
    
    q "Diagnosis Inclusion Criteria"
    a :text
    dependency :rule => "A"
    condition_A :q_diagnosis, "==", :a_yes
    condition_A :q_diagnosis, "count>0"
    
    q "Diagnosis Exclusion Criteria"
    a :text
    dependency :rule => "A"
    condition_A :q_diagnosis, "==", :a_yes
    condition_A :q_diagnosis, "count>0"
    
    q "Problem List Inclusion Criteria"
    a :text
    dependency :rule => "A"
    condition_A :q_diagnosis, "==", :a_yes
    condition_A :q_diagnosis, "count>0"
    
    q "Problem List Exclusion Criteria"
    a :text
    dependency :rule => "A"
    condition_A :q_diagnosis, "==", :a_yes
    condition_A :q_diagnosis, "count>0"
    
    q_medication "Select data fields for Medication Information?", :pick => :one
    a_yes "Yes"
    a_no "no"
    
    q "Medication Inclusion Criteria"
    a :text
    dependency :rule => "A"
    condition_A :q_medication, "==", :a_yes
    condition_A :q_medication, "count>0"
    
    q "Medication Exclusion Criteria"
    a :text
    dependency :rule => "A"
    condition_A :q_medication, "==", :a_yes
    condition_A :q_medication, "count>0"
    
    q "List of Required Medications"
    a :text
    dependency :rule => "A"
    condition_A :q_medication, "==", :a_yes
    condition_A :q_medication, "count>0"
    
    q_lab "Select data fields for Lab Information?", :pick => :one
    a_yes "Yes"
    a_no "no"
    
    q "Lab Inclusion Criteria"
    a :text
    dependency :rule => "A"
    condition_A :q_lab, "==", :a_yes
    condition_A :q_lab, "count>0"
    
    q "Lab Exclusion Criteria"
    a :text
    dependency :rule => "A"
    condition_A :q_lab, "==", :a_yes
    condition_A :q_lab, "count>0"
    
    q "List of Lab Tests"
    a :text
    dependency :rule => "A"
    condition_A :q_lab, "==", :a_yes
    condition_A :q_lab, "count>0"
    
    q_procedure "Select data fields for Procedure Information?", :pick => :one
    a_yes "Yes"
    a_no "no"
    
    q "Procedure Inclusion Criteria"
    a :text
    dependency :rule => "A"
    condition_A :q_procedure, "==", :a_yes
    condition_A :q_procedure, "count>0"
    
    q "List of Procedure Codes & Names"
    a :text
    dependency :rule => "A"
    condition_A :q_procedure, "==", :a_yes
    condition_A :q_procedure, "count>0"
    
    q "Procedure Exclusion Criteria"
    a :text
    dependency :rule => "A"
    condition_A :q_procedure, "==", :a_yes
    condition_A :q_procedure, "count>0"    
    
    q_flowsheet "Select data fields for Flowsheet?", :pick => :one
    a_yes "Yes"
    a_no "no"
    
    q "Flowsheet Inclusion Criteria"
    a :text
    dependency :rule => "A"
    condition_A :q_flowsheet, "==", :a_yes
    condition_A :q_flowsheet, "count>0"
    
    q "Flowsheet Exclusion Criteria"
    a :text
    dependency :rule => "A"
    condition_A :q_flowsheet, "==", :a_yes
    condition_A :q_flowsheet, "count>0"
    
    q_vitals "Select data fields for Vitals?", :pick => :one
    a_yes "Yes"
    a_no "no"
    
    q "Vitals Inclusion Criteria"
    a :text
    dependency :rule => "A"
    condition_A :q_vitals, "==", :a_yes
    condition_A :q_vitals, "count>0"
    
    q "Vitals Exclusion Criteria"
    a :text
    dependency :rule => "A"
    condition_A :q_vitals, "==", :a_yes
    condition_A :q_vitals, "count>0"
    
    q "List of Required Vitals"
    a :text
    dependency :rule => "A"
    condition_A :q_vitals, "==", :a_yes
    condition_A :q_vitals, "count>0"    
    
    q_prisoners "Do you want to include Prisoners in your dataset", :pick => :one
    a_yes "Yes"
    a_no "no"
    
    q "Describe Prisoner inclusion criteria"
    a :text
    dependency :rule => "A"
    condition_A :q_prisoners, "==", :a_yes
    condition_A :q_prisoners, "count>0"
    
    q "Reason for prisoner inclusion"
    a :text
    dependency :rule => "A"
    condition_A :q_prisoners, "==", :a_yes
    condition_A :q_prisoners, "count>0"
#  end
##################################################### 
#  section "Data Items to be displayed in results." do  
#####################################################
  label "<h2>Data Items to be displayed in results.</h2>"

q_children "Do you want to include children in your dataset?", :pick => :one
a_yes "Yes"
a_no "no"

q "From age"
a :integer
dependency :rule => "A"
condition_A :q_children, "==", :a_yes
condition_A :q_children, "count>0"
#validation :rule => "V"
#condition_V ">=", :integer_value => 0

q "To age"
a :integer
dependency :rule => "A"
condition_A :q_children, "==", :a_yes
condition_A :q_children, "count>0"
#validation :rule => "V"
#condition_V ">=", :integer_value => 0

q "Description"
a :string
dependency :rule => "A"
condition_A :q_children, "==", :a_yes
condition_A :q_children, "count>0"  

q_deceased "Do you need to include deceased patients", :pick => :one
a_yes "Yes"
a_no "no"

q "Inclusion criteria for deceased patients"
a :text
dependency :rule => "A"
condition_A :q_deceased, "==", :a_yes
condition_A :q_deceased, "count>0"

q "Reason for inclusion"
a :text
dependency :rule => "A"
condition_A :q_deceased, "==", :a_yes
condition_A :q_deceased, "count>0"

#  end 

#####################################################
 #  section "Date Duration (Mandatory)" do  
#####################################################    
  label "<h2>Date Duration (Mandatory)</h2>"

q "From"
a :date

q "To"
a :date

q "Additional Information"
a :text

q "Additional document to include [Upload Document]"
#a :string

q "List of publications that came out with the last ICTS services that you received"
a :text

q "List of grants that came out with the last ICTS services that you received"
a :text

q_icts_agreement "I agree to <a href=\"http://www.icts.uiowa.edu/content/acknowledging-nih-following-public-access-policy-guidelines-citation-publication\">cite ICTS in all the publications / grant applications</a> for the services received from ICTS.", :pick => :one, :is_mandatory => true
a_agree "Agree"
#validation :rule => "A"
#condition_A "==", :a_agree
#condition_A "count>0" 

q_per_irb_protocol "I confirm that the data request is as per IRB protocol", :pick => :one
a_yes "Yes"
a_no "no"

q "Date by which data is required"
a :date

  end
end
