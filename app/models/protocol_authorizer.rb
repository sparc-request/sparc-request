# Copyright © 2011 MUSC Foundation for Research Development
# All rights reserved.

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
# disclaimer in the documentation and/or other materials provided with the distribution.

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

class ProtocolAuthorizer
  
   def initialize(protocol,identity)
      @protocol, @identity = protocol, identity
   end

   def can_edit?
     return false unless @protocol && @identity
     
     #check to see if the user is a team member of the protocol and has approve or request rights
     @protocol.project_roles.each do |project_role|
       if project_role.identity_id == @identity.id && (project_role.project_rights == 'approve' || project_role.project_rights == 'request')
         return true
       end
     end
     
     @protocol.service_requests.each do |service_request|
       service_request.sub_service_requests.each do |sub_service_request|
         # check to see if the user is a super user for a related Institution, Provider, Program, or Core
         # check to see if the user is service provider for a related Provider, Program, or Core
         # admin_organizations() checks super_users and service_providers but NOT clinical_providers
         if @identity.admin_organizations().include?(sub_service_request.organization)
          return true
         end
         # check to see if the user is a clinical provider of either a Core or a Program for one of the protocol's sub service requests
         # Version 1.0: do not allow clinical providers to view or edit a protocol
      #   @identity.clinical_providers.each do |clinical_provider|
      #     if clinical_provider.organization_id == sub_service_request.organization_id || (sub_service_request.organization.type == "Core" && clinical_provider.organization_id == sub_service_request.organization.parent_id)
      #       return true      
      #     end
      #   end
       end
     end
     
     return false
   end
   
   def can_view?
     return false unless @protocol && @identity
     
     if self.can_edit?
       return true
     else
       @protocol.project_roles.each do |project_role|
         if project_role.identity_id == @identity.id && project_role.project_rights == 'view'
           return true
         end
       end
     end
     
     return false
   end
   
end
