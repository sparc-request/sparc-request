# Copyright © 2011-2019 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

task :initialize_professional_organizations => :environment do
ProfessionalOrganization.create(name: 'MUHA', org_type: 'institution')
ProfessionalOrganization.create(name: 'MUSCP', org_type: 'institution')
musc = ProfessionalOrganization.create(name: 'MUSC', org_type: 'institution')

College_of_Dental_Medicine = ProfessionalOrganization.create(name: "College of Dental Medicine", org_type: 'college', parent_id: musc.id)
College_of_Graduate_Studies = ProfessionalOrganization.create(name: "College of Graduate Studies", org_type: 'college', parent_id: musc.id)
College_of_Health_Professions = ProfessionalOrganization.create(name: "College of Health Professions", org_type: 'college', parent_id: musc.id)
College_of_Library_Sciences = ProfessionalOrganization.create(name: "College of Library Sciences", org_type: 'college', parent_id: musc.id)
College_of_Medicine = ProfessionalOrganization.create(name: "College of Medicine", org_type: 'college', parent_id: musc.id)
College_of_Nursing = ProfessionalOrganization.create(name: "College of Nursing", org_type: 'college', parent_id: musc.id)
College_of_Pharmacy = ProfessionalOrganization.create(name: "College of Pharmacy", org_type: 'college', parent_id: musc.id)

ProfessionalOrganization.create(name: "Oral Health Sciences", org_type: 'department', parent_id: College_of_Dental_Medicine.id)
ProfessionalOrganization.create(name: "Oral and Maxillofacial Surgery", org_type: 'department', parent_id: College_of_Dental_Medicine.id)
ProfessionalOrganization.create(name: "Oral Rehabilitation (includes: Advanced Education General Dentistry (AEGD) Endodontics, Implant Prosthodontics, Removable Prosthodontics, Restorative Dentistry)", org_type: 'department', parent_id: College_of_Dental_Medicine.id)
ProfessionalOrganization.create(name: "Pediatric Dentistry and Orthodontics (includes: Craniofacial Genetics, Orthodontics, Pediatric Dentistry)", org_type: 'department', parent_id: College_of_Dental_Medicine.id)
ProfessionalOrganization.create(name: "Stomatology (includes: Oral Medicine, Radiology and Emergency Services, Oral Pathology, Periodontics)", org_type: 'department', parent_id: College_of_Dental_Medicine.id)

ProfessionalOrganization.create(name: "Biochemistry and Molecular Biology", org_type: 'department', parent_id: College_of_Graduate_Studies.id)
ProfessionalOrganization.create(name: "Biomedical Imaging", org_type: 'department', parent_id: College_of_Graduate_Studies.id)
ProfessionalOrganization.create(name: "Cell and Molecular Pharmacology and Experimental Therapeutics ", org_type: 'department', parent_id: College_of_Graduate_Studies.id)
ProfessionalOrganization.create(name: "Center for Biomedical Imaging", org_type: 'department', parent_id: College_of_Graduate_Studies.id)
ProfessionalOrganization.create(name: "Center for Cell Death, Injury and Regeneration", org_type: 'department', parent_id: College_of_Graduate_Studies.id)
ProfessionalOrganization.create(name: "Clemson-MUSC Bioengineering Program", org_type: 'department', parent_id: College_of_Graduate_Studies.id)
ProfessionalOrganization.create(name: "Drug Discovery and Biomedical Sciences", org_type: 'department', parent_id: College_of_Graduate_Studies.id)
ProfessionalOrganization.create(name: "Microbiology and Immunology", org_type: 'department', parent_id: College_of_Graduate_Studies.id)
ProfessionalOrganization.create(name: "Molecular and Cellular Biology and Pathobiology Program", org_type: 'department', parent_id: College_of_Graduate_Studies.id)
ProfessionalOrganization.create(name: "Neuroscience Institute", org_type: 'department', parent_id: College_of_Graduate_Studies.id)
ProfessionalOrganization.create(name: "Pathology and Laboratory Medicine", org_type: 'department', parent_id: College_of_Graduate_Studies.id)
ProfessionalOrganization.create(name: "Public Health Science", org_type: 'department', parent_id: College_of_Graduate_Studies.id)
ProfessionalOrganization.create(name: "Regenerative Medicine and Cell Biology", org_type: 'department', parent_id: College_of_Graduate_Studies.id)

ProfessionalOrganization.create(name: "Department of Health Sciences and Research", org_type: 'department', parent_id: College_of_Health_Professions.id)
dep_of_health_professions = ProfessionalOrganization.create(name: "Department of Health Professions", org_type: 'department', parent_id: College_of_Health_Professions.id)
ProfessionalOrganization.create(name: "Department of Healthcare Leadership and Management", org_type: 'department', parent_id: College_of_Health_Professions.id)

ProfessionalOrganization.create(name: "Clinical Education", org_type: 'division', parent_id: dep_of_health_professions.id)
ProfessionalOrganization.create(name: "Anesthesia for Nurses", org_type: 'division', parent_id: dep_of_health_professions.id)
ProfessionalOrganization.create(name: "Cardivascular Perfusion", org_type: 'division', parent_id: dep_of_health_professions.id)
ProfessionalOrganization.create(name: "Healthcare Studies", org_type: 'division', parent_id: dep_of_health_professions.id)
ProfessionalOrganization.create(name: "Occupational Therapy", org_type: 'division', parent_id: dep_of_health_professions.id)
ProfessionalOrganization.create(name: "Physical Therapy", org_type: 'division', parent_id: dep_of_health_professions.id)
ProfessionalOrganization.create(name: "Physician Assistant", org_type: 'division', parent_id: dep_of_health_professions.id)

ProfessionalOrganization.create(name: "Anesthesia and Perioperative Medicine", parent_id: College_of_Medicine.id, org_type: 'department')
ProfessionalOrganization.create(name: "Biochemistry and Molecular Biology", parent_id: College_of_Medicine.id, org_type: 'department')
ProfessionalOrganization.create(name: "Cell and Molecular Pharmacology and Experimental Therapeutics", parent_id: College_of_Medicine.id, org_type: 'department')
ProfessionalOrganization.create(name: "Comparative Medicine", parent_id: College_of_Medicine.id, org_type: 'department')
ProfessionalOrganization.create(name: "Dermatology", parent_id: College_of_Medicine.id, org_type: 'department')
ProfessionalOrganization.create(name: "Family Medicine", parent_id: College_of_Medicine.id, org_type: 'department')
dep_of_medicine = ProfessionalOrganization.create(name: "Medicine", parent_id: College_of_Medicine.id, org_type: 'department')
ProfessionalOrganization.create(name: "Microbiology and Immunology", parent_id: College_of_Medicine.id, org_type: 'department')
ProfessionalOrganization.create(name: "Neurology", parent_id: College_of_Medicine.id, org_type: 'department')
dep_of_neuro = ProfessionalOrganization.create(name: "Neurosciences", parent_id: College_of_Medicine.id, org_type: 'department')
ProfessionalOrganization.create(name: "Neurosurgery", parent_id: College_of_Medicine.id, org_type: 'department')
ProfessionalOrganization.create(name: "Obstetrics and Gynecology", parent_id: College_of_Medicine.id, org_type: 'department')
ProfessionalOrganization.create(name: "Ophthalmology", parent_id: College_of_Medicine.id, org_type: 'department')
ProfessionalOrganization.create(name: "Orthopaedics ", parent_id: College_of_Medicine.id, org_type: 'department')
ProfessionalOrganization.create(name: "Otolaryngology-Head and Neck Surgery", parent_id: College_of_Medicine.id, org_type: 'department')
ProfessionalOrganization.create(name: "Pathology and Laboratory Medicine", parent_id: College_of_Medicine.id, org_type: 'department')
dep_of_ped = ProfessionalOrganization.create(name: "Pediatrics", parent_id: College_of_Medicine.id, org_type: 'department')
dep_of_psych = ProfessionalOrganization.create(name: "Psychiatry and Behavioral Sciences", parent_id: College_of_Medicine.id, org_type: 'department')
ProfessionalOrganization.create(name: "Public Health Sciences", parent_id: College_of_Medicine.id, org_type: 'department')
ProfessionalOrganization.create(name: "Radiation Oncology", parent_id: College_of_Medicine.id, org_type: 'department')
ProfessionalOrganization.create(name: "Radiology", parent_id: College_of_Medicine.id, org_type: 'department')
ProfessionalOrganization.create(name: "Regenerative Medicine and Cell Biology", parent_id: College_of_Medicine.id, org_type: 'department')
dep_of_surg = ProfessionalOrganization.create(name: "Surgery", parent_id: College_of_Medicine.id, org_type: 'department')
ProfessionalOrganization.create(name: "Urology", parent_id: College_of_Medicine.id, org_type: 'department')

ProfessionalOrganization.create(name: "Cardiology", org_type: 'division', parent_id: dep_of_medicine.id)
ProfessionalOrganization.create(name: "Emergency Medicine", org_type: 'division', parent_id: dep_of_medicine.id)
ProfessionalOrganization.create(name: "Endocrinology", org_type: 'division', parent_id: dep_of_medicine.id)
ProfessionalOrganization.create(name: "Gastroenterology & Hepatology", org_type: 'division', parent_id: dep_of_medicine.id)
ProfessionalOrganization.create(name: "Neurology", org_type: 'division', parent_id: dep_of_medicine.id)
ProfessionalOrganization.create(name: "Neurosurgery", org_type: 'division', parent_id: dep_of_medicine.id)
ProfessionalOrganization.create(name: "Pediatric Brain Tumor Program", org_type: 'division', parent_id: dep_of_medicine.id)
ProfessionalOrganization.create(name: "General Internal Medicine & Geriatrics", org_type: 'division', parent_id: dep_of_medicine.id)
ProfessionalOrganization.create(name: "Hematology/Oncology ", org_type: 'division', parent_id: dep_of_medicine.id)
ProfessionalOrganization.create(name: "Infectious Disease", org_type: 'division', parent_id: dep_of_medicine.id)
ProfessionalOrganization.create(name: "Nephrology", org_type: 'division', parent_id: dep_of_medicine.id)
ProfessionalOrganization.create(name: "Pulmonary & Critical Care", org_type: 'division', parent_id: dep_of_medicine.id)
ProfessionalOrganization.create(name: "Rheumatology & Immunology", org_type: 'division', parent_id: dep_of_medicine.id)

ProfessionalOrganization.create(name: "Alzheimer's Research & Clinical Programs (ARCP)", org_type: 'division', parent_id: dep_of_neuro.id)
ProfessionalOrganization.create(name: "Epilepsy Center", org_type: 'division', parent_id: dep_of_neuro.id)
ProfessionalOrganization.create(name: "MUSC Cholesterol Center", org_type: 'division', parent_id: dep_of_neuro.id)
ProfessionalOrganization.create(name: "Hypertension Clinic", org_type: 'division', parent_id: dep_of_neuro.id)
ProfessionalOrganization.create(name: "Palliative Care Service", org_type: 'division', parent_id: dep_of_neuro.id)

ProfessionalOrganization.create(name: "Pediatric Adolescent Medicine", org_type: 'division', parent_id: dep_of_ped.id)
ProfessionalOrganization.create(name: "Pediatric Allergy & Immunology", org_type: 'division', parent_id: dep_of_ped.id)
ProfessionalOrganization.create(name: "Pediatric Cardiology", org_type: 'division', parent_id: dep_of_ped.id)
ProfessionalOrganization.create(name: "Pediatric Cardiothoracic Surgery", org_type: 'division', parent_id: dep_of_ped.id)
ProfessionalOrganization.create(name: "Pediatric Child Abuse", org_type: 'division', parent_id: dep_of_ped.id)
ProfessionalOrganization.create(name: "Pediatric Critical Care", org_type: 'division', parent_id: dep_of_ped.id)
ProfessionalOrganization.create(name: "Pediatric Developmental Behavioral", org_type: 'division', parent_id: dep_of_ped.id)
ProfessionalOrganization.create(name: "Pediatric Developmental Neurogenetics", org_type: 'division', parent_id: dep_of_ped.id)
ProfessionalOrganization.create(name: "Pediatric Emergency Medicine", org_type: 'division', parent_id: dep_of_ped.id)
ProfessionalOrganization.create(name: "Pediatric Endocrinology", org_type: 'division', parent_id: dep_of_ped.id)
ProfessionalOrganization.create(name: "Pediatric Gastroenterology & Nutrition", org_type: 'division', parent_id: dep_of_ped.id)
ProfessionalOrganization.create(name: "Pediatric General", org_type: 'division', parent_id: dep_of_ped.id)
ProfessionalOrganization.create(name: "Pediatric Genetics", org_type: 'division', parent_id: dep_of_ped.id)
ProfessionalOrganization.create(name: "Pediatric Hematology & Oncology", org_type: 'division', parent_id: dep_of_ped.id)
ProfessionalOrganization.create(name: "Pediatric Hospitalist Services", org_type: 'division', parent_id: dep_of_ped.id)
ProfessionalOrganization.create(name: "Pediatric Infectious Diseases", org_type: 'division', parent_id: dep_of_ped.id)
ProfessionalOrganization.create(name: "Pediatric Neonatal-Perinatal Medicine", org_type: 'division', parent_id: dep_of_ped.id)
ProfessionalOrganization.create(name: "Pediatric Nephrology & Hypertenstion", org_type: 'division', parent_id: dep_of_ped.id)
ProfessionalOrganization.create(name: "Pediatric Neurology", org_type: 'division', parent_id: dep_of_ped.id)
ProfessionalOrganization.create(name: "Pediatric Pulmonology", org_type: 'division', parent_id: dep_of_ped.id)
ProfessionalOrganization.create(name: "Pediatric Rheumatology", org_type: 'division', parent_id: dep_of_ped.id)
ProfessionalOrganization.create(name: "Pediatric Neurosurgery", org_type: 'division', parent_id: dep_of_ped.id)
ProfessionalOrganization.create(name: "Pediatric Surgery", org_type: 'division', parent_id: dep_of_ped.id)

ProfessionalOrganization.create(name: "Addiction Sciences", org_type: 'division', parent_id: dep_of_psych.id)
ProfessionalOrganization.create(name: "Biobehavioral Medicine", org_type: 'division', parent_id: dep_of_psych.id)
ProfessionalOrganization.create(name: "Brain Research and Integrative Neuropharmacology (BRAIN)", org_type: 'division', parent_id: dep_of_psych.id)
ProfessionalOrganization.create(name: "Brain Stimulation Laboratory (BSL)", org_type: 'division', parent_id: dep_of_psych.id)
ProfessionalOrganization.create(name: "Child and Adolescent Psychiatry ", org_type: 'division', parent_id: dep_of_psych.id)
ProfessionalOrganization.create(name: "Clinical Neurobilogy Laboratory", org_type: 'division', parent_id: dep_of_psych.id)
ProfessionalOrganization.create(name: "Community and Public Safety Pyschiatry", org_type: 'division', parent_id: dep_of_psych.id)
ProfessionalOrganization.create(name: "Family Services Research Center", org_type: 'division', parent_id: dep_of_psych.id)
ProfessionalOrganization.create(name: "Military Sciences", org_type: 'division', parent_id: dep_of_psych.id)
ProfessionalOrganization.create(name: "National Crime Victims Center", org_type: 'division', parent_id: dep_of_psych.id)
ProfessionalOrganization.create(name: "Weight Management Center", org_type: 'division', parent_id: dep_of_psych.id)

ProfessionalOrganization.create(name: "Cardiothoracic Surgery", org_type: 'division', parent_id: dep_of_surg.id)
ProfessionalOrganization.create(name: "General Surgery", org_type: 'division', parent_id: dep_of_surg.id)
ProfessionalOrganization.create(name: "GI/Laparoscopic Surgery", org_type: 'division', parent_id: dep_of_surg.id)
ProfessionalOrganization.create(name: "Plastic Surgery", org_type: 'division', parent_id: dep_of_surg.id)
ProfessionalOrganization.create(name: "Oncologic & Endocrine Surgery", org_type: 'division', parent_id: dep_of_surg.id)
ProfessionalOrganization.create(name: "Transplant Surgery ", org_type: 'division', parent_id: dep_of_surg.id)
ProfessionalOrganization.create(name: "Vascaular Surgery", org_type: 'division', parent_id: dep_of_surg.id)

ProfessionalOrganization.create(name: "Clinical Pharmacy and Outcomes Sciences", org_type: 'department', parent_id: College_of_Pharmacy.id)
ProfessionalOrganization.create(name: "Drug Discovery and Biomedical Sciences", org_type: 'department', parent_id: College_of_Pharmacy.id)
ProfessionalOrganization.create(name: "Center for Cell Death, Injury and Regeneration", org_type: 'department', parent_id: College_of_Pharmacy.id)
ProfessionalOrganization.create(name: "Center for Cancer Drug Discovery", org_type: 'department', parent_id: College_of_Pharmacy.id)
ProfessionalOrganization.create(name: "Kennedy Center for Pharmacy Innovation", org_type: 'department', parent_id: College_of_Pharmacy.id)
ProfessionalOrganization.create(name: "Medication Safety and Efficacy Program", org_type: 'department', parent_id: College_of_Pharmacy.id)
ProfessionalOrganization.create(name: "SCORxE Program", org_type: 'department', parent_id: College_of_Pharmacy.id)

end
