class Catalog	< ActiveRecord::Base

  def self.invalid_pricing_setups_for user
    # should only validate against providers and programs the user has access to
    # if provider has it then no need to look at programs
    # if provider doesn't then all programs underneath must
    ps_array = []

    Provider.all.each do |provider|
      if !provider.pricing_setups or provider.pricing_setups.empty? # all programs better have a setup
        provider.programs.each do |program|
          if user.can_edit_entity?(program) and (!program.pricing_setups or program.pricing_setups.empty?)
            ps_array << provider if user.can_edit_entity?(provider) and not ps_array.include?(provider)
            ps_array << program
          end
        end
      end
    end
    ps_array.flatten
  end
  
end
