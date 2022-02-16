# Copyright © 2011-2020 MUSC Foundation for Research Development~
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

class ProtocolMergesReport < ReportingModule
  $canned_reports << name unless $canned_reports.include? name # update global variable so that we can populate the list, report won't show in the list without this, unless is necessary so we don't add on refresh in dev. mode

  ################## BEGIN REPORT SETUP #####################

  def self.title
    "Protocol Merges"
  end

  # see app/reports/test_report.rb for all options
  def default_options
    {
      "Merged Date Range" => {:field_type => :date_range, :for => "protocols_merged_date", :from => "2012-03-01".to_date, :to => Date.today}
    }
  end

  # see app/reports/test_report.rb for all options
  def column_attrs
    attrs = {}

    attrs["Date of Merge"] = "self.updated_at.try(:strftime, \"%D\")"
    attrs["Master Protocol ID"] = :master_protocol_id
    attrs["Subordinate Protocol ID"] = :merged_protocol_id
    attrs["Merged By"] = "identity.try(:full_name)"
    attrs["Short Title"] = "master_protocol.try(:short_title)"
    attrs["PI"] = "master_protocol.try(:primary_pi).try(:full_name)"
    attrs["IRB#"] = "master_protocol.try(:irb_records).length > 1 ? '1' : master_protocol.try(:irb_records).length == 1 ? master_protocol.try(:irb_records).first.try(:irb_of_record) : ' '"
    attrs

  end

  ################## END REPORT SETUP  #####################

  ################## BEGIN QUERY SETUP #####################
  # def table => primary table to query
  # includes, preload, where, uniq, order, and group get passed to AR methods, http://apidock.com/rails/v3.2.13/ActiveRecord/QueryMethods
  # def includes => other tables to include for where queries
  # def preload => other tables to eager load
  # def where => conditions for query
  # def uniq => return distinct records
  # def group => group by this attribute (including table name is always a safe bet, ex. identities.id)
  # def order => order by these attributes (include table name is always a safe bet, ex. identities.id DESC, protocols.title ASC)
  # Primary table to query
  def table
    ProtocolMerge
  end

  def includes
  end

  # Conditions
  def where args={}

    from_date = (args[:protocols_merged_date_from].nil? ? self.default_options["Merged Date Range"][:from] : DateTime.strptime(args[:protocols_merged_date_from], "%m/%d/%Y")).to_s(:db)
    to_date = (args[:protocols_merged_date_to].nil? ? self.default_options["Merged Date Range"][:to] : DateTime.strptime(args[:protocols_merged_date_to], "%m/%d/%Y")).strftime("%Y-%m-%d 23:59:59")
    merged_date = from_date..to_date

    return {:updated_at => merged_date}

  end

   # Return only uniq records for
  def uniq
    :master_protocol_id
  end

  def group
  end

  def order
    "protocol_merges.master_protocol_id ASC"
  end


  ##################  END QUERY SETUP   #####################
end

