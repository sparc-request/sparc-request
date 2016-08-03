# Copyright © 2011-2016 MUSC Foundation for Research Development.
# All rights reserved.
class SetSubsidyOverriddenIfSubmitted < ActiveRecord::Migration
  def up
    ssrs = SubServiceRequest.where(:status => "submitted")
    ssrs.each do |ssr|
      if ssr.subsidy && !ssr.subsidy.overridden
        ssr.subsidy.update_attributes(:overridden => true)
      end
    end
  end

  def down
  end
end
