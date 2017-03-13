task :professional_organizations_update => :environment do
  #  Adding Dean's Office under College of Medicine
  College_of_Medicine = ProfessionalOrganization.find(8)
  ProfessionalOrganization.create(name: "Dean's Office", org_type: 'department', parent_id: College_of_Medicine.id)

  # Adding VPAA college and the department and divisions under it
  musc = ProfessionalOrganization.find(3)
  vpaa = ProfessionalOrganization.create(name: "Vice President for Academic Affairs (VPAA)", org_type: 'college', parent_id: musc.id)
  ovpr = ProfessionalOrganization.create(name: "Office of Vice President for Research (OVPR)", org_type: 'department', parent_id: vpaa.id)

  ProfessionalOrganization.create(name: "Institutional Animal Care and Use Committee (IACUC)", org_type: 'division', parent_id: ovpr.id)
  ProfessionalOrganization.create(name: "Institutional Biosafety Committee (IBC)", org_type: 'division', parent_id: ovpr.id)
  ProfessionalOrganization.create(name: "Institutional Review Board (IRB)", org_type: 'division', parent_id: ovpr.id)
  ProfessionalOrganization.create(name: "Office of Clinical Research (OCR)", org_type: 'division', parent_id: ovpr.id)
  ProfessionalOrganization.create(name: "Office of Research and Sponsored Programs (ORSP)", org_type: 'division', parent_id: ovpr.id)
  ProfessionalOrganization.create(name: "Office of the Provost", org_type: 'division', parent_id: ovpr.id)
  ProfessionalOrganization.create(name: "Research Integrity Committee (RIC)", org_type: 'division', parent_id: ovpr.id)
  ProfessionalOrganization.create(name: "South Carolina Translational Research (SCTR)", org_type: 'division', parent_id: ovpr.id)
  ProfessionalOrganization.create(name: "Vice President of Research (VPR)", org_type: 'division', parent_id: ovpr.id)
end