module Dashboard
  class GroupedOrganizations
    include ActionView::Helpers::TagHelper

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
      org_options = []
      inactive = content_tag(:strong, I18n.t(:dashboard)[:protocol_filters][:inactive], class: 'text-danger filter-identifier')
      orgs.each do |org|
        name = content_tag(:span, org.name)
        name = name + inactive unless org.is_available
        org_options << [name, org.id]
      end
      org_options
    end
  end
end