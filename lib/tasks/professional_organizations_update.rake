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