module Dashboard
  class GroupedOrganizations
    def initialize(organizations)
      @organizations = organizations
    end

    def collect_grouped_options
      groups = @organizations.group_by(&:type)
      options = ["Institution", "Provider", "Program", "Core"].map do |type|
        next unless groups[type].present?
        [type.pluralize, extract_name_and_id(groups[type])]
      end
      options.compact
    end

    private

    def extract_name_and_id(orgs)
      orgs.map { |org| [org.name, org.id] }
    end
  end
end