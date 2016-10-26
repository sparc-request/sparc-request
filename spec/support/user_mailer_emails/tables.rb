module EmailHelpers
  
  def protocol_information_table
    expect(@mail).to have_xpath "//table//strong[text()='Study Information']"
    expect(@mail).to have_xpath "//th[text()='Study ID']/following-sibling::td[text()='#{study.id}']"
    expect(@mail).to have_xpath "//th[text()='Short Title']/following-sibling::td[text()='#{study.short_title}']"
    expect(@mail).to have_xpath "//th[text()='Study Title']/following-sibling::td[text()='#{study.title}']"
    expect(@mail).to have_xpath "//th[text()='Sponsor Name']/following-sibling::td[text()='#{study.sponsor_name}']"
    expect(@mail).to have_xpath "//th[text()='Funding Source']/following-sibling::td[text()='#{study.funding_source.capitalize}']"
  end

  def user_information_table_with_epic_col
    expect(@mail).to have_xpath "//table//strong[text()='User Information']"
    expect(@mail).to have_xpath "//th[text()='User Modification']/following-sibling::th[text()='Contact Information']/following-sibling::th[text()='Role']/following-sibling::th[text()='SPARC Proxy Rights']/following-sibling::th[text()='Epic Access']"
    expect(@mail).to have_xpath "//td[text()='#{@modified_identity.full_name}']/following-sibling::td[text()='#{@modified_identity.email}']/following-sibling::td[text()='#{@modified_identity.project_roles.first.role.upcase}']/following-sibling::td[text()='#{@modified_identity.project_roles.first.display_rights}']"
    if @modified_identity.project_roles.first.epic_access == false
      expect(@mail).to have_xpath "//td[text()='No']"
    else
      expect(@mail).to have_xpath "//td[text()='Yes']"
    end
  end

  def user_information_table_without_epic_col
    expect(@mail).to have_xpath "//table//strong[text()='User Information']"
    expect(@mail).to have_xpath "//th[text()='User Modification']/following-sibling::th[text()='Contact Information']/following-sibling::th[text()='Role']/following-sibling::th[text()='SPARC Proxy Rights']"
    expect(@mail).not_to have_xpath "//following-sibling::th[text()='Epic Access']"
    expect(@mail).to have_xpath "//td[text()='#{@modified_identity.full_name}']/following-sibling::td[text()='#{@modified_identity.email}']/following-sibling::td[text()='#{@modified_identity.project_roles.first.role.upcase}']/following-sibling::td[text()='#{@modified_identity.project_roles.first.display_rights}']"

    if @modified_identity.project_roles.first.epic_access == false
      expect(@mail).not_to have_xpath "//td[text()='No']"
    else
      expect(@mail).not_to have_xpath "//td[text()='Yes']"
    end
  end
end

RSpec.configure do |config|
  config.include EmailHelpers
  config.include EmailSpec::Helpers
  config.include EmailSpec::Matchers
end